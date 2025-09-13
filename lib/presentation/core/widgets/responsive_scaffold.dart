import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;

    // Determine layout type based on screen size
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor ?? circuitColors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                circuitColors.surface,
                circuitColors.surface.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: _buildResponsiveBody(
            context,
            screenWidth,
            screenHeight,
            isTablet,
            isDesktop,
            isLandscape,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveBody(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    bool isTablet,
    bool isDesktop,
    bool isLandscape,
  ) {
    // Calculate responsive margins and padding
    final horizontalPadding =
        _getHorizontalPadding(screenWidth, isTablet, isDesktop);
    final verticalPadding = _getVerticalPadding(screenHeight, isLandscape);

    if (isDesktop) {
      // Desktop layout with maximum content width
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: body,
          ),
        ),
      );
    } else if (isTablet) {
      // Tablet layout with moderate margins
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: body,
      );
    } else {
      // Mobile layout with minimal margins
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: body,
      );
    }
  }

  double _getHorizontalPadding(
      double screenWidth, bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return 32;
    } else if (isTablet) {
      return 24;
    } else {
      return 16;
    }
  }

  double _getVerticalPadding(double screenHeight, bool isLandscape) {
    if (isLandscape && screenHeight < 600) {
      // Reduce vertical padding in landscape on small screens
      return 8;
    }
    return 16;
  }
}

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.tabletBreakpoint = 768,
    this.desktopBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= desktopBreakpoint && desktop != null) {
          return desktop!;
        } else if (width >= tabletBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double spacing;
  final EdgeInsets padding;
  final int minCrossAxisCount;
  final int maxCrossAxisCount;
  final double maxCrossAxisExtent;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.all(16),
    this.minCrossAxisCount = 1,
    this.maxCrossAxisCount = 6,
    this.maxCrossAxisExtent = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.extent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        children: children,
      ),
    );
  }
}
