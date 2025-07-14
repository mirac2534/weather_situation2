import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const ErrorCard({
    super.key,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final maxCardWidth = deviceWidth * 0.9;
    final horizontalPadding = deviceWidth * 0.05;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxCardWidth),
        margin:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        padding: EdgeInsets.symmetric(
          horizontal: deviceWidth * 0.04,
          vertical: deviceWidth * 0.035,
        ),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.95),
          borderRadius: BorderRadius.circular(deviceWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: deviceWidth * 0.03,
              offset: Offset(0, deviceWidth * 0.01),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.white, size: deviceWidth * 0.06),
                SizedBox(width: deviceWidth * 0.03),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: deviceWidth * 0.035,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (onClose != null)
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: onClose,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text("Kapat"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
