import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uk.co.tcork.stardew_companion/src/provider/BundleProvider.dart';
import 'package:uk.co.tcork.stardew_companion/src/provider/ItemProvider.dart';
import '../widgets/SquareAvatar.dart';

class BundleScreen extends StatelessWidget {
  final BundleProvider bundleProvider;

  BundleScreen({@required this.bundleProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BundleProvider>.value(
      value: bundleProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<BundleProvider>(
            builder: (context, provider, _) {
              return Text(provider.bundle.name);
            },
          ),
        ),
        body: Consumer<BundleProvider>(
          builder: (context, provider, _) {
            return ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                return _buildListItem(context, provider.items[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, ItemProvider itemProvider) {
    return ChangeNotifierProvider.value(
      value: itemProvider,
      child: Consumer<ItemProvider>(builder: (context, provider, _) {
        var callback = getItemTappedCallback;
        var onChanged = callback;
        var itemComplete = provider.item.complete;
        bool bundleCompleted = bundleProvider.numCompleted >=
            provider.item.plBundle.numItemsRequired;

        if (bundleCompleted && !itemComplete) {
          onChanged = null;
        }

        return ListTile(
          title: Text(provider.item.name),
          leading: SquareAvatar(
            backgroundImage: AssetImage(provider.item.iconPath),
          ),
          trailing: Checkbox(
            activeColor: Colors.green,
            tristate: true,
            value: onChanged == null ? null : itemComplete,
            onChanged:
                onChanged == null ? null : (value) => callback(provider)(),
          ),
          onTap: callback(provider),
        );
      }),
    );
  }

  void Function() getItemTappedCallback(ItemProvider provider) {
    bool bundleCompleted =
        bundleProvider.numCompleted >= provider.item.plBundle.numItemsRequired;

    if (bundleCompleted && !provider.complete) return null;

    return () {
      provider.complete = !provider.item.complete;

      if (provider.item.complete) {
        bundleProvider.numCompleted++;
      } else {
        bundleProvider.numCompleted--;
      }
    };
  }
}
