import 'package:flutter/material.dart';

class HeadlineDisplay extends StatelessWidget {
  const HeadlineDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: Column(
        children: [
        //   text saying headline display 1 going from textTheme.displayLarge all the way to textTheme.bodySmall, 3 for display,
          //   3 for healine, 3 for title, 3 for body

          Text("Display 1", style: Theme.of(context).textTheme.displayLarge,),
          Text("Display 2", style: Theme.of(context).textTheme.displayMedium,),
          Text("Display 3", style: Theme.of(context).textTheme.displaySmall,),

          Text("Headline 1", style: Theme.of(context).textTheme.headlineLarge,),
          Text("Headline 2", style: Theme.of(context).textTheme.headlineMedium,),
          Text("Headline 3", style: Theme.of(context).textTheme.headlineSmall,),

          Text("Title is 1", style: Theme.of(context).textTheme.titleLarge,),
          Text("Title is 2", style: Theme.of(context).textTheme.titleMedium,),
          Text("Title 3", style: Theme.of(context).textTheme.titleSmall,),

          Text("Body 1", style: Theme.of(context).textTheme.bodyLarge,),
          Text("Body 2", style: Theme.of(context).textTheme.bodyMedium,),
          Text("Body 3", style: Theme.of(context).textTheme.bodySmall,),

          Text("Label 3", style: Theme.of(context).textTheme.labelSmall,),
        ],
      ))),
    );
  }
}
