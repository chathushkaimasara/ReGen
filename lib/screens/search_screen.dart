import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          toolbarHeight: 70,
          title: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
          bottom: const TabBar(tabs: [Tab(text: 'Images'), Tab(text: 'Videos')]),
        ),
        body: TabBarView(
          children: [
            _buildGrid('posts', isVideo: false),
            _buildGrid('videos', isVideo: true),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(String collection, {required bool isVideo}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final docs = snapshot.data!.docs.where((doc) {
          String title = (doc['title'] ?? '').toString().toLowerCase();
          return title.contains(searchQuery);
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String url = isVideo ? '' : (data['imageUrl'] ?? ''); 

            return GestureDetector(
              onTap: () {
                if (isVideo) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SingleVideoScreen(videoData: data)));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SingleImageScreen(postData: data)));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.secondary,
                  image: url.isNotEmpty ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
                ),
                child: Center(
                  child: isVideo 
                    ? Icon(Icons.play_circle_fill, size: 50, color: Theme.of(context).colorScheme.primary.withOpacity(0.5))
                    : null
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SingleImageScreen extends StatelessWidget {
  final Map<String, dynamic> postData;
  const SingleImageScreen({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    String imageUrl = postData['imageUrl'] ?? '';
    String title = postData['title'] ?? 'Untitled';
    String prompt = postData['prompt'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: imageUrl.isNotEmpty ? Image.network(imageUrl, fit: BoxFit.fitWidth) : Container(height: 300, color: Theme.of(context).colorScheme.secondary),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Prompt:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(prompt, style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SingleVideoScreen extends StatefulWidget {
  final Map<String, dynamic> videoData;
  const SingleVideoScreen({super.key, required this.videoData});

  @override
  State<SingleVideoScreen> createState() => _SingleVideoScreenState();
}

class _SingleVideoScreenState extends State<SingleVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    String videoUrl = widget.videoData['videoUrl'] ?? '';
    if (videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _isInitialized = true);
            _controller.play();
            _controller.setLooping(true);
          }
        });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.videoData['title'] ?? 'Untitled';
    String prompt = widget.videoData['prompt'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _isInitialized
              ? GestureDetector(
                  onTap: () => setState(() => _controller.value.isPlaying ? _controller.pause() : _controller.play()),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Prompt: $prompt', 
                style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic),
                maxLines: 3, overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}
