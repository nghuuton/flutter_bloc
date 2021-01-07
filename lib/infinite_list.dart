import 'package:demo_app/blocs/comment_bloc.dart';
import 'package:demo_app/events/comment_events.dart';
import 'package:demo_app/states/comment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfiniteList extends StatefulWidget {
  @override
  _InfiniteListState createState() => _InfiniteListState();
}

class _InfiniteListState extends State<InfiniteList> {
  CommentBloc _commentBloc;
  final _scrollController = ScrollController();
  final _scrollThreadhold = 250.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _commentBloc = BlocProvider.of(context);
    _commentBloc.add(CommentFetchedEvent());
    _scrollController.addListener(() {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScrollExtent - currentScroll <= _scrollThreadhold) {
        //scroll to the end of 1 page
        _commentBloc.add(CommentFetchedEvent());
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Infinite List'),
      ),
      body: BlocBuilder<CommentBloc, CommentState>(
        builder: (context, state) {
          if (state is CommentStateInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is CommentStateFailure) {
            return Center(
              child: Text('Fetch Data Error'),
            );
          }
          if (state is CommentStateSuccess) {
            if (state.comments.isEmpty) {
              return Center(
                child: Text('Empty comments'),
              );
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                if (index >= state.comments.length) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListTile(
                    leading: Text('${state.comments[index].id}'),
                    title: Text('${state.comments[index].email}'),
                    subtitle: Text('${state.comments[index].body}'),
                    isThreeLine: true,
                  );
                }
              },
              itemCount: state.hasReachedEnd ? state.comments.length : state.comments.length + 1,
              controller: _scrollController,
            );
          } else {
            return Center(child: Text('Other states..'));
          }
        },
      ),
    );
  }
}
