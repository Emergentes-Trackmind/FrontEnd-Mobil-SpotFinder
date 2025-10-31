import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final IconData icon;
  final String? routeToNavigate;
  final VoidCallback? onClose;
  final Color iconColor;
  final Color buttonColor;

  const SuccessDialog({
    super.key,
    required this.message,
    required this.buttonLabel,
    required this.icon,
    this.routeToNavigate,
    this.onClose,
    this.iconColor = const Color(0xFF3B82F6),
    this.buttonColor = const Color(0xFF3B82F6),
  }) : assert(
         routeToNavigate != null || onClose != null,
         'Se debe proporcionar routeToNavigate o onClose',
       );

  static void show({
    required BuildContext context,
    required String message,
    required String buttonLabel,
    required IconData icon,
    String? routeToNavigate,
    VoidCallback? onClose,
    Color iconColor = const Color(0xFF3B82F6),
    Color buttonColor = const Color(0xFF3B82F6),
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: message,
          buttonLabel: buttonLabel,
          icon: icon,
          routeToNavigate: routeToNavigate,
          onClose: onClose,
          iconColor: iconColor,
          buttonColor: buttonColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 100),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (routeToNavigate != null) {
                  Navigator.of(context).pushNamed(routeToNavigate!);
                } else if (onClose != null) {
                  onClose!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
