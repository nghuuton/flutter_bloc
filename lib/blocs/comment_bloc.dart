import 'package:demo_app/events/comment_events.dart';
import 'package:demo_app/services/services.dart';
import 'package:demo_app/states/comment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final NUMBER_OF_COMMENTS_PER_PAGE = 20;
  //initial State
  CommentBloc() : super(CommentStateInitial());
  @override
  Stream<CommentState> mapEventToState(CommentEvent event) async* {
    if (event is CommentFetchedEvent &&
        !(state is CommentStateSuccess && (state as CommentStateSuccess).hasReachedEnd)) {
      try {
        if (state is CommentStateInitial) {
          final comments = await getCommentsFromApi(0, NUMBER_OF_COMMENTS_PER_PAGE);
          yield CommentStateSuccess(comments: comments, hasReachedEnd: false);
        } else if (state is CommentStateSuccess) {
          final currentState = state as CommentStateSuccess;
          int finalIndexOfCurrentPage = currentState.comments.length;
          final comments = await getCommentsFromApi(finalIndexOfCurrentPage, NUMBER_OF_COMMENTS_PER_PAGE);
          if (comments.isEmpty) {
            yield currentState.cloneWith(hasReachedEnd: true);
          } else {
            yield CommentStateSuccess(comments: currentState.comments + comments, hasReachedEnd: false);
          }
        }
      } catch (exception) {
        yield CommentStateFailure();
      }
    }
  }
}
