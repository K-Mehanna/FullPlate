import 'package:cibu/database/donors_manager.dart';
import 'package:cibu/models/donor_info.dart';
import 'package:cibu/widgets/custom_alert_dialog.dart';
import 'package:cibu/widgets/custom_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cibu/database/kitchens_manager.dart';
import 'package:cibu/database/orders_manager.dart';
import 'package:cibu/models/job_info.dart';
import 'package:cibu/models/kitchen_info.dart';
import 'package:cibu/pages/title_page.dart';
import 'history_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  final OrdersManager ordersManager = OrdersManager();
  List<JobInfo> completedJobs = [];
  Map<String, KitchenInfo> kitchensInfo = {};

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DonorInfo? donor; // should display donor

  @override
  void initState() {
    super.initState();
    fetchCompletedJobs();

    DonorsManager().getDonorCompletion(_auth.currentUser!.uid, (donor) {
      if (!mounted) return;
      setState(() {
        this.donor = donor;
      });
    });
  }

  void fetchCompletedJobs() {
    final user = FirebaseAuth.instance.currentUser;
    //const user = "HAO9gLWbTaT7z16pBoLGz019iSC3";
    ordersManager.getJobsCompletion(
      OrderStatus.COMPLETED,
      user!.uid,
      null,
      (jobs) {
        if (!mounted) return;
        setState(() {
          completedJobs = jobs;
        });
        for (var job in jobs) {
          KitchensManager().getKitchenCompletion(job.kitchenId, (kitchen) {
            if (!mounted) return;
            setState(() {
              kitchensInfo[kitchen.kitchenId] = kitchen;
            });
          });
        }
      },
    );
  }

  Future<void> _deletionConfirmation(BuildContext outerContext) async {
    showDialog(
      context: outerContext,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text("Are you sure you want to delete your account?"),
          content: const Text(
              "This will delete ALL your currently accepted and pending jobs.\n\nThis action cannot be undone."),
          actions: [
            adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            adaptiveAction(
              context: context,
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount(outerContext);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.currentUser!.uid)
          .delete();

      await FirebaseFirestore.instance
          .collection("donors")
          .doc(_auth.currentUser!.uid)
          .delete();

      // faraz can you delete the jobs that are not completed (i.e pending and accepted jobs)
      // also need to send cancel request

      await _auth.currentUser!.delete();

      if (context.mounted) {
        showCustomSnackBar(context, "Account deleted successfully");
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TitlePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print("Error happened (${context.mounted}): ${e.message}");
      if (context.mounted) {
        showCustomSnackBar(context, e.message!);
      }
    }
  }

  Widget profileButton(BuildContext context, String text, IconData icon,
      void Function() onPressed, Color backgroundColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: textColor),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 6.0,
          padding: const EdgeInsets.all(16.0),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _signOut() {
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TitlePage()),
      );
    });
  }

  void _navigateToHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(
          completedJobs: completedJobs,
          kitchensInfo: kitchensInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        //backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: theme.colorScheme.surfaceContainer,
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text(
                      donor?.name ?? '', // Placeholder name
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Address",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text(
                      donor?.address ?? '', // Placeholder address
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text(
                      _auth.currentUser!.email!, // Placeholder email
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            profileButton(
                context,
                "View History",
                Icons.history,
                _navigateToHistoryPage,
                theme.colorScheme.tertiaryContainer,
                theme.colorScheme.onTertiaryContainer),
            SizedBox(height: 16.0),
            Spacer(),
            profileButton(
                context,
                "Sign Out",
                Icons.logout,
                _signOut,
                theme.colorScheme.inverseSurface,
                theme.colorScheme.onInverseSurface),
            SizedBox(height: 16.0),
            profileButton(
                context,
                "Delete Account",
                Icons.delete,
                () async => _deletionConfirmation(context),
                theme.colorScheme.errorContainer,
                theme.colorScheme.onErrorContainer),
          ],
        ),
      ),
    );
  }
}
