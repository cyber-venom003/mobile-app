import 'package:flutter/material.dart';
import 'package:mobile_app/routes/subtopics.dart';
import '../models/topicsList.dart';
import 'package:scroll_to_index/scroll_to_index.dart';


class TopicList extends StatefulWidget {
  dynamic dataset;
  TopicList({@required this.dataset});
  @override
  _TopicListState createState() => _TopicListState();
}

class _TopicListState extends State<TopicList> {
  
  String searchQuery;
  AutoScrollController controller;
  final scrollDirection = Axis.vertical;
  
  TopicsList topics = TopicsList();
  var parentSet = <String>{};
  List<String> parentList = [];
  void getTopics(){
    setState(() {
      topics = TopicsList.fromJson(widget.dataset['topics']);
    });
  }

  void getParents(){
    for (int i = 0 ; i < topics.topics.length ; ++i){
      if(topics.topics[i].parent == null){
        parentSet.add("Other Topics");
      }
      else {
        parentSet.add("${topics.topics[i].parent.name}");
      }
    }
    parentList = parentSet.toList();
    print(parentList);
  }

  @override
  void initState() {
    getTopics();
    super.initState();
    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: scrollDirection
    );
    getParents();
  }

  void searchTopic(String query){
    int index = parentList.indexWhere((parent) => parent == query);
    _scrollToIndex(index);
  }

  Future _scrollToIndex(int index) async {
    await controller.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
    controller.highlight(index);
  }

  createAlertDialog(BuildContext context){
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('Topic Name'),
          content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    onChanged: (value){
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search Topic",
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color:Colors.purple,
                  ),
                ),
                onPressed: () {
                  searchTopic(searchQuery);
                  Navigator.of(context).pop();
                },
              ),
            FlatButton(
                child: Text(
                  'Close',
                  style: TextStyle(
                    color:Colors.purple,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ), 
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search , color: Colors.white,),
            onPressed: (){
              createAlertDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        controller: controller,
        scrollDirection: scrollDirection,
        itemCount: (parentList.length == 0) ? 0 : parentList.length,  
        itemBuilder: (context , index){
          return Card(
                  child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: getTile(index),
                ),
          );
        },
      ),
    );
  }
  Widget getTile(int index){
  return _wrapScrollTag(
    index: index,
    child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SubTopicList(parent: parentList[index] , topics: topics,)));
            },
            child: ListTile(
              title: Text(
                parentList[index],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
        ),
    ),
    );
  }
  Widget _wrapScrollTag({int index, Widget child}) => AutoScrollTag(
    key: ValueKey(index),
    controller: controller,
    index: index,
    child: child,
    highlightColor: Colors.purple.withOpacity(0.1),
  );
}

