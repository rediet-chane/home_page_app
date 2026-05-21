// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String productsUrl = 'https://fakestoreapi.com/products';
  static const String youtubeApiKey = 'AIzaSyBXxAHfg_dgRCPhmgzhvOhZCYsvkLtD4Ks'; // 🔴 PUT YOUR API KEY HERE!
  
  // Fetch REAL products from FakeStore API
  static Future<List<Map<String, dynamic>>> fetchProducts({int limit = 20}) async {
    try {
      final response = await http.get(Uri.parse('$productsUrl?limit=$limit'));
      
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
  
  // Fetch product reviews (using comments API as reviews)
  static Future<List<Map<String, dynamic>>> fetchProductReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$productId/comments'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((review) {
          return {
            'name': review['name'],
            'email': review['email'],
            'body': review['body'],
            'rating': (review['id'] % 5) + 1,
            'date': DateTime.now().subtract(Duration(days: review['id'])),
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }
  
  // Fetch REAL posts from API
  static Future<List<Post>> fetchPosts({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?_limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Post> posts = [];
        
        for (var postJson in jsonResponse) {
          final commentsResponse = await http.get(
            Uri.parse('$baseUrl/posts/${postJson['id']}/comments'),
          );
          int commentCount = 0;
          if (commentsResponse.statusCode == 200) {
            List commentsList = json.decode(commentsResponse.body);
            commentCount = commentsList.length;
          }
          
          int likes = (postJson['id'] * 37) % 2000 + 50;
          
          Post post = Post.fromJson(postJson);
          post.likes = likes;
          post.comments = commentCount;
          post.isLiked = false;
          
          posts.add(post);
        }
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }
  
  // Fetch REAL comments from API
  static Future<List<Comment>> fetchCommentsForPost(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((comment) {
          Comment newComment = Comment.fromJson(comment);
          newComment.likes = (newComment.id * 7) % 100;
          newComment.isLiked = false;
          return newComment;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }
  
  // Add a new comment
  static Future<bool> addComment(int postId, String name, String body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        body: {
          'postId': postId.toString(),
          'name': name,
          'email': 'user@example.com',
          'body': body,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }
  
  // Fetch REAL YouTube videos
  static Future<List<Map<String, dynamic>>> fetchYouTubeVideos({String query = 'beauty makeup tutorial', int maxResults = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=$maxResults&q=$query&type=video&key=$youtubeApiKey'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          return List<Map<String, dynamic>>.from(data['items']);
        }
      }
      return _getMockVideos();
    } catch (e) {
      print('Error fetching videos: $e');
      return _getMockVideos();
    }
  }
  
  static List<Map<String, dynamic>> _getMockVideos() {
    return [
      {
        'id': {'videoId': 'dQw4w9WgXcQ'},
        'snippet': {
          'title': 'Beauty Tutorial: Natural Makeup Look',
          'description': 'Learn how to achieve a natural everyday makeup look',
          'thumbnails': {'medium': {'url': 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg'}}
        }
      },
      {
        'id': {'videoId': '9bZkp7q19f0'},
        'snippet': {
          'title': 'Skincare Routine for Glowing Skin',
          'description': 'Step by step skincare routine for healthy skin',
          'thumbnails': {'medium': {'url': 'https://img.youtube.com/vi/9bZkp7q19f0/mqdefault.jpg'}}
        }
      },
    ];
  }
}