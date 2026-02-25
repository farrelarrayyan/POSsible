import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Fungsi open link
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    // Buka di app external
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Jika gagal
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka link!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Pembuat'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto profil
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/images/foto_profil.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nama
            const Text(
              'Farrel Arrayyan Adrianshah', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Panggilan: Farrel', 
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Hobi
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hobi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    '• Tinkering with tech stuff\n• Main Game\n• Tidur 😴',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Minat
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Minat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Terbuka untuk belajar apapun, tapi lagi ngulik tentang:\n• Mobile Development\n• Web Development\n• Cybersecurity',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bagian medsos
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Media Sosial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('LinkedIn'),
                    subtitle: const Text('Farrel Arrayyan Adrianshah'),
                    onTap: () {
                      _launchURL(context, 'https://www.linkedin.com/in/farrel-arrayyan/');
                    },
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('GitHub'),
                    subtitle: const Text('farrelarrayyan'),
                    onTap: () {
                      _launchURL(context, 'https://github.com/farrelarrayyan');
                    },
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Instagram'),
                    subtitle: const Text('@farrelarrayyan'),
                    onTap: () {
                      _launchURL(context, 'https://instagram.com/farrelarrayyan');
                    },
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('X/Twitter'),
                    subtitle: const Text('@sistemtigaduo'),
                    onTap: () {
                      _launchURL(context, 'https://x.com/sistemtigaduo');
                    },
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              'Made with ❤️ for oprec MobDev RISTEK Fasilkom UI 2026 :)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}