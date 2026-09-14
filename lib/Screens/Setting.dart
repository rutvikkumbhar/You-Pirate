import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:you_pirate_app/Services/SettingServices.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {

  bool incognitoDownload = false;
  bool downloadNotification = true;

  @override
  void initState() {
    super.initState();
    loadSettings();

  }
  
  Future<void> loadSettings() async {
    incognitoDownload = await SettingServices.isIncognitoDownload();
    downloadNotification = await SettingServices.isDownloadNotificationEnabled();
    setState((){});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text("Settings",
          style: GoogleFonts.poppins(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w500
          ),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Downloads", style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white60
            ),),
            SizedBox(height: 10,),
            Row(
              children: [
                Image.asset("assets/images/incognito-icon.png", height: 26,width: 26,),
                SizedBox(width: 15,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Incognito Download", style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                      ),),
                      SizedBox(height: 3,),
                      Text("Don't save downloaded files to your download history",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white60
                        ),),
                    ],
                  ),
                ),
                Switch(
                    value: incognitoDownload,
                    activeThumbColor: Color(0xff503bd1),
                    activeTrackColor: Color(0xff503bd1).withValues(alpha: 0.2),
                    inactiveThumbColor: Color(0xff503bd1),
                    inactiveTrackColor: Color(0xFF2C2C2C),
                    trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                    onChanged: (value) async {
                      await SettingServices.setIncognitoDownload(value);
                      setState(() {
                        incognitoDownload = value;
                      });
                    }
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                height: 0.1,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey,
              ),
            ),Row(
              children: [
                SizedBox(width: 2,),
                Icon( downloadNotification ? Boxicons.bxs_bell : Boxicons.bxs_bell_off,
                  color: Colors.white,size: 22,),
                SizedBox(width: 17,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Download Notifications", style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                      ),),
                      SizedBox(height: 3,),
                      Text("Show download progress and completion notification",
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white60
                        ),),
                    ],
                  ),
                ),
                Switch(
                    value: downloadNotification,
                    activeThumbColor: Color(0xff503bd1),
                    activeTrackColor: Color(0xff503bd1).withValues(alpha: 0.2),
                    inactiveThumbColor: Color(0xff503bd1),
                    inactiveTrackColor: Color(0xFF2C2C2C),
                    trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                    onChanged: (value) async {
                      await SettingServices.setDownloadNotification(value);
                      setState(() {
                        downloadNotification = value;
                      });
                    }
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}