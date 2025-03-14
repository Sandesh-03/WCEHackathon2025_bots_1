import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pages/chat_screen.dart';
import '../../pages/home_screen.dart';
import '../../pages/about_us_screen.dart';
import '../../pages/settings_screen.dart';
import '../../providers/location_data_provider.dart';
import 'custom_list_tile.dart';
import 'header.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key, required String apiData});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isCollapsed = false;

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationDataProvider = Provider.of<LocationDataProvider>(context);
    return SafeArea(
      child: AnimatedContainer(
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: 500),
        width: _isCollapsed ? 300 : 70,
        height: 600,
        margin: const EdgeInsets.only(bottom: 10, top: 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: Color.fromRGBO(20, 20, 20, 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomDrawerHeader(isColapsed: _isCollapsed),
              const Divider(color: Colors.grey),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.home_outlined,
                title: 'Home',
                infoCount: 0,
                onTap: () => _navigateToScreen(context, const HomeScreen()),
              ),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.message_rounded,
                title: 'Chat',
                infoCount: 0,
                onTap: () => _navigateToScreen(
                    context,
                    ChatScreen(
                      locationData: locationDataProvider,
                    )),
              ),
              const Divider(color: Colors.grey),
              const Spacer(),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.person,
                title: 'About us',
                infoCount: 0,
                onTap: () => _navigateToScreen(context, const AboutUSScreen()),
              ),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.settings,
                title: 'Settings',
                infoCount: 0,
                onTap: () => _navigateToScreen(context, const SettingsScreen()),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: _isCollapsed
                    ? Alignment.bottomRight
                    : Alignment.bottomCenter,
                child: IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    _isCollapsed
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
