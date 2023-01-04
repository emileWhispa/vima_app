import 'package:flutter/material.dart';

class SearchDemoSearchDelegate extends SearchDelegate {
  final Widget Function(String query) _data;
  final String? label;
  final List<Widget>? actions;

  SearchDemoSearchDelegate(this._data,{this.label,this.actions});

  @override
  String? get searchFieldLabel => label ?? super.searchFieldLabel;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _data(query);
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super
        .appBarTheme(context)
        .copyWith(primaryColor: Theme.of(context).scaffoldBackgroundColor);
  }


  String prev = "";

  @override
  List<Widget> buildActions(BuildContext context) {
    var widget = query.isEmpty
        ? IconButton(
            tooltip: 'Voice Search',
            icon: const Icon(Icons.mic),
            onPressed: () {

            },
          )
        : IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear),
            onPressed: () {
              query = '';
              showSuggestions(context);
            },
          );
    return actions != null ? (List.from(actions!)..add(widget)) : [widget];
  }
}
