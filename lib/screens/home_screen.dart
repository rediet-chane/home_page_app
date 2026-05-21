import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/post.dart';
import '../models/comment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Post> posts = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedPosts = await ApiService.fetchPosts(limit: 10);
      final fetchedProducts = await ApiService.fetchProducts(limit: 10);
      final fetchedVideos = await ApiService.fetchYouTubeVideos(maxResults: 10);
      
      if (mounted) {
        setState(() {
          posts = fetchedPosts;
          products = fetchedProducts;
          videos = fetchedVideos;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _launchYouTube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildProductsTab(),
                    _buildPostsTab(),
                    _buildVideosTab(),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Videos'),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => _showProductDetail(product),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      product['image'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 40),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['title'] ?? 'Product',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            (product['rating']?['rate'] ?? 4.5).toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product['rating']?['count'] ?? 0})',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product['price']?.toString() ?? '0'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    if (posts.isEmpty) {
      return const Center(child: Text('No posts found'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  post.body,
                  style: TextStyle(color: Colors.grey.shade700),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          post.isLiked = !post.isLiked;
                          if (post.isLiked) {
                            post.likes++;
                          } else {
                            post.likes--;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: post.isLiked ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(post.likes.toString()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _showComments(post),
                      child: Row(
                        children: [
                          const Icon(Icons.comment, size: 20, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(post.comments.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosTab() {
    if (videos.isEmpty) {
      return const Center(child: Text('No videos found'));
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        final videoId = video['id']?['videoId'] ?? '';
        final title = video['snippet']?['title'] ?? 'Video';
        final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
        
        return GestureDetector(
          onTap: () => _launchYouTube(videoId),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        thumbnailUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.video_library, size: 40),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(Icons.play_circle_filled, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showProductDetail(Map<String, dynamic> product) async {
    final reviews = await ApiService.fetchProductReviews(product['id'] ?? 1);
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product['image'] ?? '',
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product['title'] ?? 'Product',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) => Icon(
                  i < (product['rating']?['rate'] ?? 4).floor()
                      ? Icons.star
                      : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                )),
                const SizedBox(width: 8),
                Text(
                  '${product['rating']?['rate'] ?? 4.5} (${product['rating']?['count'] ?? 0} reviews)',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${product['price']?.toString() ?? '0'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              product['description'] ?? 'No description available',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews (${reviews.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAddReviewDialog(product['id'] ?? 1),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Write Review'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text(review['name'][0].toUpperCase()),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        i < review['rating'] ? Icons.star : Icons.star_border,
                                        size: 12,
                                        color: Colors.amber,
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDate(review['date']),
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(review['body']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(Post post) async {
    List<Comment> comments = await ApiService.fetchCommentsForPost(post.id);
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final TextEditingController commentController = TextEditingController();
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments (${comments.length})',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      comment.name[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          comment.email,
                                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        comment.isLiked = !comment.isLiked;
                                        if (comment.isLiked) {
                                          comment.likes++;
                                        } else {
                                          comment.likes--;
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          comment.isLiked ? Icons.favorite : Icons.favorite_border,
                                          size: 14,
                                          color: comment.isLiked ? Colors.red : Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(comment.likes.toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(comment.body),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _showReplyDialog(post, comment, comments, setModalState);
                                },
                                child: const Text('Reply', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (commentController.text.isNotEmpty) {
                            final newComment = Comment(
                              id: DateTime.now().millisecondsSinceEpoch,
                              postId: post.id,
                              name: 'You',
                              email: 'you@example.com',
                              body: commentController.text,
                              likes: 0,
                              isLiked: false,
                            );
                            comments.add(newComment);
                            commentController.clear();
                            setModalState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment added!')),
                            );
                          }
                        },
                        icon: const Icon(Icons.send),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReplyDialog(Post post, Comment parentComment, List<Comment> comments, Function setModalState) {
    final TextEditingController replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reply to ${parentComment.name}'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.isNotEmpty) {
                final replyComment = Comment(
                  id: DateTime.now().millisecondsSinceEpoch,
                  postId: post.id,
                  name: 'You',
                  email: 'reply@example.com',
                  body: 'Replying to ${parentComment.name}: ${replyController.text}',
                  likes: 0,
                  isLiked: false,
                );
                comments.add(replyComment);
                setModalState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply posted!')),
                );
              }
            },
            child: const Text('Post Reply'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(int productId) {
    final TextEditingController reviewController = TextEditingController();
    double rating = 5;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Write a Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setDialogState(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reviewController,
                  decoration: const InputDecoration(
                    hintText: 'Write your review...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reviewController.text.isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review added! Thank you!')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}