import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../templates/templates.dart';
import '../themes/app_theme.dart';
import '../services/update_service.dart';
import '../services/expiry_service.dart';
import '../widgets/update_dialog.dart';
import '../widgets/telegram_dialog.dart';
import '../widgets/announcement_dialog.dart';
import '../widgets/expiry_dialog.dart';
import 'webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  Color get _primary => AppConfig.useCustomColors
      ? AppConfig.customPrimaryColor
      : AppTheme.getPalette(AppConfig.themeTemplate).primary;

  Color get _bg => AppConfig.useCustomColors
      ? AppConfig.customBackgroundColor
      : AppTheme.getPalette(AppConfig.themeTemplate).background;

  Color get _text => AppConfig.useCustomColors
      ? AppConfig.customTextPrimary
      : AppTheme.getPalette(AppConfig.themeTemplate).textPrimary;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(
        parent: _mainCtrl, curve: const Interval(0, 0.65, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.65, end: 1.0).animate(CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0, 0.75, curve: Curves.easeOutBack)));
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _mainCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _mainCtrl.forward();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(Duration(seconds: AppConfig.splashDurationSeconds));
    if (!mounted) return;

    // Check expiry first
    if (AppConfig.enableExpiry && ExpiryService.isExpired()) {
      _navigateTo(const WebViewScreen());
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: !AppConfig.expiryBlockApp,
          builder: (_) => const ExpiryDialog(),
        );
      }
      return;
    }

    _navigateTo(const WebViewScreen());
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Check update
    if (AppConfig.enableAutoUpdate) {
      final info = await UpdateService.checkForUpdate();
      if (info != null && mounted) {
        showDialog(
          context: context,
          barrierDismissible: !info.forceUpdate,
          builder: (_) => UpdateDialog(updateInfo: info),
        );
        return;
      }
    }

    // Telegram dialog
    if (AppConfig.showTelegramDialog && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getInt('tg_shown') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cool = AppConfig.telegramDialogCooldownDays * 86400000;
      if (now - last > cool) {
        await prefs.setInt('tg_shown', now);
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const TelegramDialog(),
          );
          return;
        }
      }
    }

    // Announcement dialog
    if (AppConfig.showAnnouncementDialog && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getBool('announcement_shown') ?? false;
      if (!AppConfig.announcementShowOnce || !shown) {
        if (AppConfig.announcementShowOnce) {
          await prefs.setBool('announcement_shown', true);
        }
        await Future.delayed(
            Duration(seconds: AppConfig.announcementDelaySeconds));
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => const AnnouncementDialog(),
          );
        }
      }
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (AppConfig.splashTemplate) {
      case SplashTemplate.minimalText:
        return _buildMinimalSplash();
      case SplashTemplate.neonGlow:
        return _buildNeonSplash();
      case SplashTemplate.slideUp:
        return _buildSlideUpSplash();
      case SplashTemplate.gradientWave:
          return _buildGradientWaveSplash();
        case SplashTemplate.iconLarge:
          return _buildIconLargeSplash();
        case SplashTemplate.splitScreen:
          return _buildSplitScreenSplash();
        case SplashTemplate.typewriter:
          return _buildTypewriterSplash();
        case SplashTemplate.fadeCircle:
          return _buildFadeCircleSplash();
        case SplashTemplate.photoFull:
          return _buildPhotoFullSplash();
      default:
        return _buildClassicSplash();
    }
  }

  Widget _buildClassicSplash() {
    return Stack(
      children: [
        // Background decoration blobs
        Positioned(
          top: -100,
          right: -80,
          child: _blob(260, _primary.withOpacity(0.12)),
        ),
        Positioned(
          bottom: -80,
          left: -70,
          child: _blob(220, _primary.withOpacity(0.08)),
        ),
        Center(
          child: AnimatedBuilder(
            animation: _mainCtrl,
            builder: (_, child) => FadeTransition(
              opacity: _fade,
              child: ScaleTransition(scale: _scale, child: child),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (AppConfig.showSplashLogo) _buildLogo(),
                const SizedBox(height: 28),
                Text(
                  AppConfig.splashTitle,
                  style: TextStyle(
                    color: _text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _taglineChip(),
                const SizedBox(height: 56),
                if (AppConfig.showSplashProgress)
                  AppConfig.splashAnimatedDots
                      ? _AnimatedDots(color: _primary)
                      : SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: _primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                const SizedBox(height: 72),
                if (AppConfig.showPoweredBy) _poweredByRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalSplash() {
    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (_, child) =>
          FadeTransition(opacity: _fade, child: child),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppConfig.splashTitle,
              style: TextStyle(
                color: _text,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppConfig.splashTagline,
              style: TextStyle(
                  color: _primary, fontSize: 14, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonSplash() {
    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (_, child) =>
          FadeTransition(opacity: _fade, child: child),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _primary.withOpacity(0.6),
                      blurRadius: 60,
                      spreadRadius: 20),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.black,
                  child: Icon(Icons.web_rounded,
                      size: 70, color: _primary),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(AppConfig.splashTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                if (AppConfig.showPoweredBy) ...[
                  const SizedBox(height: 8),
                  _poweredByRow(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideUpSplash() {
    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (_, child) =>
          SlideTransition(position: _slide, child: child),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (AppConfig.showSplashLogo) _buildLogo(),
            const SizedBox(height: 24),
            Text(
              AppConfig.splashTitle,
              style: TextStyle(
                color: _text,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            _taglineChip(),
            const SizedBox(height: 48),
            if (AppConfig.showSplashProgress)
              _AnimatedDots(color: _primary),
            const SizedBox(height: 60),
            if (AppConfig.showPoweredBy) _poweredByRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final size = AppConfig.splashLogoSize;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: AppConfig.splashRoundedCircle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: AppConfig.splashRoundedCircle
            ? null
            : BorderRadius.circular(AppConfig.splashLogoRadius),
        border: Border.all(color: _primary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.35),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppConfig.splashRoundedCircle
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(AppConfig.splashLogoRadius - 2),
        child: AppConfig.splashLogoAsset.isNotEmpty
            ? Image.asset(
                AppConfig.splashLogoAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _defaultLogoIcon(size),
              )
            : _defaultLogoIcon(size),
      ),
    );
  }

  Widget _defaultLogoIcon(double size) => Container(
        color: _primary.withOpacity(0.15),
        child: Icon(Icons.web_rounded, size: size * 0.55, color: _primary),
      );

  Widget _taglineChip() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: _primary.withOpacity(0.4)),
        ),
        child: Text(
          AppConfig.splashTagline,
          style: TextStyle(
            color: _text.withOpacity(0.85),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _poweredByRow() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt_rounded,
              size: 13, color: _text.withOpacity(0.35)),
          const SizedBox(width: 4),
          Text(
            AppConfig.poweredBy,
            style: TextStyle(
              color: _text.withOpacity(0.35),
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: color),
      );


    // ──────────────────────────────────────────────────────────────────────
    //  NEW SPLASH TEMPLATES
    // ──────────────────────────────────────────────────────────────────────

    Widget _buildGradientWaveSplash() {
      return AnimatedBuilder(
        animation: _mainCtrl,
        builder: (_, child) => FadeTransition(opacity: _fade, child: child),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primary.withOpacity(0.85),
                    _bg,
                    _primary.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            // Wave decoration
            Positioned(
              bottom: -60,
              left: -40,
              right: -40,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              right: -20,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (AppConfig.showSplashLogo) _buildLogo(),
                    const SizedBox(height: 24),
                    Text(
                      AppConfig.splashTitle,
                      style: TextStyle(
                        color: _text,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _taglineChip(),
                    const SizedBox(height: 48),
                    if (AppConfig.showSplashProgress) _AnimatedDots(color: _primary),
                  ],
                ),
              ),
            ),
            if (AppConfig.showPoweredBy)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(child: _poweredByRow()),
              ),
          ],
        ),
      );
    }

    Widget _buildIconLargeSplash() {
      return AnimatedBuilder(
        animation: _mainCtrl,
        builder: (_, child) => ScaleTransition(scale: _scale, child:
          FadeTransition(opacity: _fade, child: child)),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large icon with glow
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withOpacity(0.12),
                      boxShadow: [
                        BoxShadow(color: _primary.withOpacity(0.4), blurRadius: 50, spreadRadius: 10),
                      ],
                    ),
                    child: AppConfig.splashLogoAsset.isNotEmpty
                      ? ClipOval(child: Image.asset(AppConfig.splashLogoAsset, fit: BoxFit.cover))
                      : Icon(Icons.web_rounded, size: 90, color: _primary),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppConfig.splashTitle,
                    style: TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.splashTagline,
                    style: TextStyle(color: _primary, fontSize: 14),
                  ),
                  const SizedBox(height: 56),
                  if (AppConfig.showSplashProgress) _AnimatedDots(color: _primary),
                ],
              ),
            ),
            if (AppConfig.showPoweredBy)
              Positioned(bottom: 32, left: 0, right: 0,
                child: Center(child: _poweredByRow())),
          ],
        ),
      );
    }

    Widget _buildSplitScreenSplash() {
      return AnimatedBuilder(
        animation: _mainCtrl,
        builder: (_, child) => FadeTransition(opacity: _fade, child: child),
        child: Column(
          children: [
            // Top half — logo
            Expanded(
              child: Container(
                color: _primary.withOpacity(0.08),
                child: Center(
                  child: ScaleTransition(
                    scale: _scale,
                    child: AppConfig.showSplashLogo
                        ? _buildLogo()
                        : Icon(Icons.web_rounded, size: 100, color: _primary),
                  ),
                ),
              ),
            ),
            // Divider accent
            Container(height: 3, color: _primary),
            // Bottom half — text
            Expanded(
              child: Container(
                color: _bg,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConfig.splashTitle,
                        style: TextStyle(
                          color: _text,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConfig.splashTagline,
                        style: TextStyle(color: _text.withOpacity(0.6), fontSize: 15),
                      ),
                      const SizedBox(height: 32),
                      if (AppConfig.showSplashProgress) _AnimatedDots(color: _primary),
                      const SizedBox(height: 24),
                      if (AppConfig.showPoweredBy) _poweredByRow(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildTypewriterSplash() {
      return _TypewriterSplash(
        title: AppConfig.splashTitle,
        tagline: AppConfig.splashTagline,
        primary: _primary,
        bg: _bg,
        text: _text,
        showProgress: AppConfig.showSplashProgress,
        showPoweredBy: AppConfig.showPoweredBy,
        poweredByWidget: _poweredByRow(),
      );
    }

    Widget _buildFadeCircleSplash() {
      return AnimatedBuilder(
        animation: _mainCtrl,
        builder: (_, child) {
          final v = _fade.value;
          return Stack(
            children: [
              // Expanding circle reveal
              Center(
                child: Container(
                  width: 300 * v,
                  height: 300 * v,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withOpacity(0.12 * (1 - v * 0.5)),
                  ),
                ),
              ),
              Opacity(opacity: v, child: child),
            ],
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (AppConfig.showSplashLogo) _buildLogo(),
              const SizedBox(height: 28),
              Text(AppConfig.splashTitle,
                style: TextStyle(color: _text, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _taglineChip(),
              const SizedBox(height: 52),
              if (AppConfig.showSplashProgress) _AnimatedDots(color: _primary),
              const SizedBox(height: 60),
              if (AppConfig.showPoweredBy) _poweredByRow(),
            ],
          ),
        ),
      );
    }

    Widget _buildPhotoFullSplash() {
      // Full-screen logo/image with text overlay
      return Stack(
        fit: StackFit.expand,
        children: [
          // Full background
          if (AppConfig.splashLogoAsset.isNotEmpty)
            Image.asset(AppConfig.splashLogoAsset, fit: BoxFit.cover)
          else
            Container(color: _primary.withOpacity(0.2)),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, _bg.withOpacity(0.9), _bg],
              ),
            ),
          ),
          // Text at bottom
          Positioned(
            bottom: 80,
            left: 32,
            right: 32,
            child: AnimatedBuilder(
              animation: _mainCtrl,
              builder: (_, child) => FadeTransition(opacity: _fade, child: child),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConfig.splashTitle,
                    style: TextStyle(color: _text, fontSize: 34, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(AppConfig.splashTagline,
                    style: TextStyle(color: _text.withOpacity(0.7), fontSize: 16)),
                  const SizedBox(height: 24),
                  if (AppConfig.showSplashProgress) _AnimatedDots(color: _primary),
                ],
              ),
            ),
          ),
          if (AppConfig.showPoweredBy)
            Positioned(
              bottom: 28, left: 0, right: 0,
              child: AnimatedBuilder(
                animation: _mainCtrl,
                builder: (_, child) => FadeTransition(opacity: _fade, child: child!),
                child: Center(child: _poweredByRow()),
              ),
            ),
        ],
      );
    }
  
}
// ── Animated Dots ─────────────────────────────────────────────────────────────
class _AnimatedDots extends StatefulWidget {
  final Color color;
  const _AnimatedDots({required this.color});
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _ctls = [];
  final List<Animation<double>> _anims = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 550));
      final a = Tween<double>(begin: 0.25, end: 1.0)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
      _ctls.add(c);
      _anims.add(a);
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(_anims[i].value),
            ),
          ),
        ),
      ),
    );
  }
}

  // ── Typewriter Splash ────────────────────────────────────────────────────────────────────
  class _TypewriterSplash extends StatefulWidget {
    final String title;
    final String tagline;
    final Color primary;
    final Color bg;
    final Color text;
    final bool showProgress;
    final bool showPoweredBy;
    final Widget poweredByWidget;

    const _TypewriterSplash({
      required this.title, required this.tagline, required this.primary,
      required this.bg, required this.text, required this.showProgress,
      required this.showPoweredBy, required this.poweredByWidget,
    });

    @override
    State<_TypewriterSplash> createState() => _TypewriterSplashState();
  }

  class _TypewriterSplashState extends State<_TypewriterSplash> with SingleTickerProviderStateMixin {
    late AnimationController _ctrl;
    String _displayed = '';
    int _charIndex = 0;

    @override
    void initState() {
      super.initState();
      _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 80))
        ..addListener(_onTick)
        ..repeat();
    }

    void _onTick() {
      if (_charIndex < widget.title.length) {
        setState(() => _displayed = widget.title.substring(0, ++_charIndex));
      } else {
        _ctrl.stop();
      }
    }

    @override
    void dispose() { _ctrl.dispose(); super.dispose(); }

    @override
    Widget build(BuildContext context) {
      return Container(
        color: widget.bg,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_displayed,
                      style: TextStyle(color: widget.text, fontSize: 32, fontWeight: FontWeight.w900)),
                    AnimatedOpacity(
                      opacity: _charIndex < widget.title.length ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(width: 3, height: 36, color: widget.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.tagline,
                  style: TextStyle(color: widget.primary, fontSize: 15)),
                const SizedBox(height: 48),
                if (widget.showProgress) _AnimatedDots(color: widget.primary),
                const SizedBox(height: 60),
                if (widget.showPoweredBy) widget.poweredByWidget,
              ],
            ),
          ),
        ),
      );
    }
  }
  
