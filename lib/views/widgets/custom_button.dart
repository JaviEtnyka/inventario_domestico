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
  final EdgeInsetsGeometry? padding;
  
  const CustomButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.height,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primaryColor;
    
    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
    
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: buttonColor, width: 1.5),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
          minimumSize: isFullWidth ? Size.fromHeight(height ?? 48) : null,
          elevation: 2,
          shadowColor: buttonColor.withOpacity(0.5),
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
  final double size;
  
  const ActionButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
    this.size = 36,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primaryColor;
    
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Center(
              child: Icon(
                icon,
                color: buttonColor,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Nuevo componente: Botón flotante de acción
class FloatingActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  
  const FloatingActionIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
    this.tooltip,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppTheme.secondaryColor).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Tooltip(
              message: tooltip ?? '',
              child: Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}