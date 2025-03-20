// views/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutlined;
  final bool isFullWidth;
  final double? height;
  
  const CustomButton({super.key, 
    required this.text,
    this.icon,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).primaryColor;
    
    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: buttonColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
          minimumSize: isFullWidth ? Size.fromHeight(height ?? 48) : null,
        ),
        child: buttonContent,
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
          minimumSize: isFullWidth ? Size.fromHeight(height ?? 48) : null,
        ),
        child: buttonContent,
      );
    }
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;
  
  const ActionButton({super.key, 
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).primaryColor;
    
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: buttonColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}