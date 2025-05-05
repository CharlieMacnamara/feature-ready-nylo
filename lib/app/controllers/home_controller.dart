import 'package:url_launcher/url_launcher.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HomeController extends NyController {
  onTapDocumentation() async {
    await launchUrl(Uri.parse("https://nylo.dev/docs"));
  }

  onTapGithub() async {
    await launchUrl(Uri.parse("https://github.com/nylo-core/nylo"));
  }

  onTapChangeLog() async {
    await launchUrl(Uri.parse("https://github.com/nylo-core/nylo/releases"));
  }

  onTapYouTube() async {
    await launchUrl(Uri.parse("https://m.youtube.com/@nylo_dev"));
  }

  onTapX() async {
    await launchUrl(Uri.parse("https://x.com/nylo_dev"));
  }
}
