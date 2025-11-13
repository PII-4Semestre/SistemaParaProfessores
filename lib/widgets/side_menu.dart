import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../services/theme_controller.dart';
import 'drawer_user_header.dart';

class SideMenu extends StatelessWidget {
  final String name;
  final String? subtitle;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const SideMenu({
    super.key,
    required this.name,
    this.subtitle,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ]
              : [
                  Color(0xFFFFF5EB),
                  Color(0xFFFFE4D6),
                  Color(0xFFF6E2CD),
                ],
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            DrawerUserHeader(name: name, subtitle: subtitle),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _buildMenuItem(
                      context,
                      icon: (isSelected 
                          ? destinations[index].selectedIcon
                          : destinations[index].icon) ?? Icon(Icons.circle),
                      label: destinations[index].label,
                      isSelected: isSelected,
                      onTap: () => onSelect(index),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Divider(
                    color: (Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Color(0xFFFFB88C)).withOpacity(0.2),
                    thickness: 1,
                  ),
                  SizedBox(height: 8),
                  _buildThemeToggle(context),
                  SizedBox(height: 8),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required Widget icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF1CB3C2) : Color(0xFFFF9B71);
    final secondaryTextColor = isDark ? Colors.white70 : Color(0xFF8D6E63);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isSelected ? 16 : 8,
          sigmaY: isSelected ? 16 : 8,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [
                      primaryColor.withOpacity(0.3),
                      primaryColor.withOpacity(0.1),
                    ]
                  : isDark
                      ? [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.4),
                        ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1.5,
              color: isSelected
                  ? primaryColor.withOpacity(0.5)
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : Color(0xFFFFB88C).withOpacity(0.3),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.7),
                                ],
                              )
                            : null,
                        color: isSelected 
                            ? null 
                            : isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: isSelected ? Colors.white : secondaryTextColor,
                          size: 22,
                        ),
                        child: icon,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : secondaryTextColor,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (context, mode, _) {
        final isDarkMode = mode == ThemeMode.dark;
        final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDarkTheme ? Colors.white70 : Color(0xFF8D6E63);
        final iconColor = isDarkTheme ? Colors.white70 : Color(0xFF8D6E63);
        final backgroundColor = isDarkTheme ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5);
        final borderColor = isDarkTheme ? Colors.white.withOpacity(0.1) : Color(0xFFFFB88C).withOpacity(0.3);
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkTheme
                      ? [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [
                          Colors.white.withOpacity(0.7),
                          Colors.white.withOpacity(0.4),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 1.5,
                  color: borderColor,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDarkMode ? Iconsax.moon : Iconsax.sun_1,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tema',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      Switch(
                        value: isDarkMode,
                        onChanged: (v) => ThemeController.instance.set(
                          v ? ThemeMode.dark : ThemeMode.light,
                        ),
                        activeColor: isDarkTheme ? Color(0xFF1CB3C2) : Color(0xFFFF9B71),
                        activeTrackColor: isDarkTheme 
                            ? Color(0xFF1CB3C2).withOpacity(0.5)
                            : Color(0xFFFF9B71).withOpacity(0.5),
                        inactiveThumbColor: iconColor,
                        inactiveTrackColor: backgroundColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoutColor = Color(0xFFED2152); // Vermelho em ambos os temas
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                logoutColor.withOpacity(0.2),
                logoutColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1.5,
              color: logoutColor.withOpacity(0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFED2152),
                            Color(0xFFB81840),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: logoutColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.logout,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Sair',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
