import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/isl_glosser.dart';
import '../../core/widgets/sign_player.dart';
import '../../data/models/sign_entry.dart';
import '../../data/repositories/sign_dictionary_repository.dart';
import '../../main.dart';
import '../history/widgets/history_drawer.dart';

/// Text & Speech to Sign Screen.
///
/// Features:
/// - Fast text input with instant ISL gloss translation
/// - Real-time ISL grammar transformer (SOV reordering, stop word filtering)
/// - Interactive Sign Player with sequential animations and gesture instructions
/// - Speech recognition trigger (dictation / mic)
/// - Preset quick phrase starter chips
class SpeechToSignScreen extends ConsumerStatefulWidget {
  const SpeechToSignScreen({super.key});

  @override
  ConsumerState<SpeechToSignScreen> createState() => _SpeechToSignScreenState();
}

class _SpeechToSignScreenState extends ConsumerState<SpeechToSignScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isListening = false;
  GlossResult? _glossResult;
  List<SignPlaybackItem> _playbackItems = [];
  String _lastTranslatedText = '';

  static const List<String> _samplePhrases = [
    'Hello, how are you?',
    'I am going to school',
    'What is your name?',
    'Thank you for your help',
    'Please need doctor',
    'We study sign language',
  ];

  @override
  void initState() {
    super.initState();
    // Default initial translation so user sees the sign player in action immediately
    _translateText('Hello, how are you?');
    _textController.text = 'Hello, how are you?';
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _translateText(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _glossResult = null;
        _playbackItems = [];
        _lastTranslatedText = '';
      });
      return;
    }

    final result = IslGlosser.gloss(trimmed);
    final deduplicatedTokens = IslGlosser.deduplicate(result.activeTokens);
    final resolvedSigns =
        SignDictionaryRepository.instance.resolve(deduplicatedTokens);

    setState(() {
      _glossResult = result;
      _playbackItems = resolvedSigns;
      _lastTranslatedText = trimmed;
    });
  }

  void _onPhraseSelected(String phrase) {
    HapticFeedback.selectionClick();
    _textController.text = phrase;
    _textController.selection =
        TextSelection.fromPosition(TextPosition(offset: phrase.length));
    _translateText(phrase);
    _focusNode.unfocus();
  }

  void _toggleMic() {
    HapticFeedback.mediumImpact();
    setState(() => _isListening = !_isListening);

    if (_isListening) {
      // Simulate listening and picking up speech after 1.8 seconds
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listening to voice in English/Hindi/Marathi…'),
          duration: Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted || !_isListening) return;
        const simulatedVoice = 'I want to eat food';
        _textController.text = simulatedVoice;
        _translateText(simulatedVoice);
        setState(() => _isListening = false);
      });
    }
  }

  void _copyGloss() {
    if (_glossResult == null || _glossResult!.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _glossResult!.glossString));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ISL Gloss: "${_glossResult!.glossString}"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final removedStopWords = _glossResult?.allTokens
            .where((t) => t.isStopWord)
            .map((t) => t.originalWord)
            .toSet()
            .toList() ??
        [];

    return Scaffold(
      drawer: const HistoryDrawer(),
      backgroundColor:
          isDark ? const Color(0xFF161C19) : const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.only(left: 14),
            child: IconButton(
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF242F2B) : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF384E49)
                        : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF202522),
                ),
              ),
              tooltip: 'Past History',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Text to Sign',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF202522),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ISL Natural Grammar (SOV)',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF55605A),
              size: 22,
            ),
            tooltip: 'How ISL Translation Works',
            onPressed: () => _showExplanationDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Input Container with Mic & Clear ────────────────
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2623) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.forestSage
                        : (isDark
                            ? const Color(0xFF2C3A35)
                            : const Color(0xFFE5EAE7)),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: 2,
                      minLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.white : const Color(0xFF202522),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type any phrase in English…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _translateText,
                      onSubmitted: _translateText,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Clear Button
                        if (_textController.text.isNotEmpty)
                          InkWell(
                            onTap: () {
                              _textController.clear();
                              _translateText('');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: isDark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),

                        // Right: Mic Action Button & Translate Pill
                        Row(
                          children: [
                            // Mic Button
                            GestureDetector(
                              onTap: _toggleMic,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isListening
                                      ? AppColors.error
                                      : (isDark
                                          ? const Color(0xFF2C3A35)
                                          : const Color(0xFFF3F5F4)),
                                ),
                                child: Icon(
                                  _isListening
                                      ? Icons.stop_rounded
                                      : Icons.mic_rounded,
                                  size: 18,
                                  color: _isListening
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF344C43)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Translate / Done button
                            GestureDetector(
                              onTap: () =>
                                  _translateText(_textController.text),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.forestSage,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.translate_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Translate',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Quick Phrase Starters ───────────────────────────
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _samplePhrases.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final phrase = _samplePhrases[index];
                    final isSelected = _textController.text == phrase;

                    return GestureDetector(
                      onTap: () => _onPhraseSelected(phrase),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF2C3A35)
                                  : const Color(0xFFD6E8DE))
                              : (isDark
                                  ? const Color(0xFF1E2623)
                                  : const Color(0xFFF3F5F4)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.forestSage
                                : (isDark
                                    ? const Color(0xFF2C3A35)
                                    : const Color(0xFFE5EAE7)),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            phrase,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF202522))
                                  : (isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF55605A)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── ISL Transformation Inspector Card ───────────────
              if (_glossResult != null && !_glossResult!.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2623)
                        : const Color(0xFFF3F5F4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C3A35)
                          : const Color(0xFFE5EAE7),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.forestSage
                                      .withValues(alpha: 0.15),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 13,
                                  color: AppColors.forestSage,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ISL GLOSS SEQUENCE (SOV)',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: isDark
                                      ? const Color(0xFFA5CDB6)
                                      : const Color(0xFF344C43),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _copyGloss,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF242F2B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF384E49)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.copy_rounded,
                                    size: 11,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF374151),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copy',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Gloss Tokens Wrap
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _playbackItems.map((item) {
                          final category = item.sign.category;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: category.backgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: category.color.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.sign.icon,
                                  size: 12,
                                  color: category.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.sign.gloss,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: category.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      // If stop words were removed, show helpful note
                      if (removedStopWords.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Removed stop words (not used in ISL): ${removedStopWords.join(", ")}',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Interactive Sequential Sign Player ──────────────
              if (_playbackItems.isNotEmpty) ...[
                SignPlayer(
                  key: ValueKey(_lastTranslatedText),
                  items: _playbackItems,
                  originalText: _lastTranslatedText,
                ),
              ] else ...[
                // Empty state
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2623)
                        : const Color(0xFFF3F5F4),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C3A35)
                          : const Color(0xFFE5EAE7),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.forestSage.withValues(alpha: 0.12),
                        ),
                        child: const Icon(
                          Icons.translate_rounded,
                          size: 30,
                          color: AppColors.forestSage,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Type or Speak to Sign',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF202522),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter a sentence in English, and VACHIKA will convert it into Indian Sign Language (SOV grammar) with step-by-step gesture instructions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  void _showExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.forestSage.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.sign_language_rounded,
                      size: 22,
                      color: AppColors.forestSage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'How ISL Works',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF202522),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '1. SOV Word Order:\nUnlike English (SVO: "I eat apple"), Indian Sign Language uses Subject-Object-Verb ("ME APPLE EAT").\n\n'
                '2. Dropping Auxiliary Verbs:\nWords like "am, is, are, was, were, to, of, the" are removed in ISL.\n\n'
                '3. Fingerspelling Fallback:\nWords not found in the dictionary are spelled out letter by letter using the ISL two-hand manual alphabet.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestSage,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
