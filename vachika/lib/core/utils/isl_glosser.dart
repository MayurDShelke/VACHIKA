/// ISL (Indian Sign Language) Glossing Engine
///
/// Converts English text into ISL gloss tokens by:
/// 1. Tokenizing and normalizing
/// 2. Removing stop words (articles, linking verbs, prepositions)
/// 3. Mapping pronouns to ISL forms
/// 4. Reordering to ISL SOV (Subject-Object-Verb) grammar
///
/// ISL Grammar Rules (simplified):
/// - SOV word order: Subject → Object → Verb
/// - No articles (a, an, the)
/// - No linking verbs (is, am, are, was, were)
/// - Minimal prepositions
/// - Question words come first
/// - Negation follows the verb
library;

/// Represents a single token in the ISL gloss output.
class GlossToken {
  /// The original English word before processing.
  final String originalWord;

  /// The ISL gloss form (uppercase).
  final String glossForm;

  /// Part-of-speech tag for reordering.
  final GlossTokenType type;

  /// Whether this word was a stop word (removed from ISL).
  final bool isStopWord;

  const GlossToken({
    required this.originalWord,
    required this.glossForm,
    required this.type,
    this.isStopWord = false,
  });

  @override
  String toString() => 'GlossToken($glossForm, $type)';
}

/// Part-of-speech categories for ISL reordering.
enum GlossTokenType {
  pronoun,
  noun,
  verb,
  adjective,
  adverb,
  question,
  number,
  negation,
  greeting,
  other,
}

class IslGlosser {
  IslGlosser._();

  // ── Stop Words (removed in ISL) ─────────────────────────────
  static const _stopWords = <String>{
    // Articles
    'a', 'an', 'the',
    // Linking / auxiliary verbs
    'is', 'am', 'are', 'was', 'were', 'be', 'been', 'being',
    'do', 'does', 'did',
    'has', 'have', 'had',
    'will', 'would', 'shall', 'should', 'can', 'could', 'may', 'might', 'must',
    // Prepositions
    'to', 'of', 'in', 'on', 'at', 'for', 'with', 'from', 'by', 'about',
    'into', 'through', 'during', 'before', 'after', 'above', 'below',
    'between', 'under', 'over',
    // Conjunctions
    'and', 'but', 'or', 'so', 'yet', 'nor',
    // Others
    'it', 'its', 'that', 'which', 'just', 'very', 'really', 'also',
    'too', 'then', 'than', 'some', 'any', 'each', 'every',
  };

  // ── Pronoun Mapping ─────────────────────────────────────────
  static const _pronounMap = <String, String>{
    'i': 'ME',
    'me': 'ME',
    'my': 'MY',
    'mine': 'MY',
    'myself': 'ME',
    'you': 'YOU',
    'your': 'YOUR',
    'yours': 'YOUR',
    'yourself': 'YOU',
    'he': 'HE',
    'him': 'HE',
    'his': 'HIS',
    'himself': 'HE',
    'she': 'SHE',
    'her': 'HER',
    'hers': 'HER',
    'herself': 'SHE',
    'we': 'WE',
    'us': 'WE',
    'our': 'OUR',
    'ours': 'OUR',
    'ourselves': 'WE',
    'they': 'THEY',
    'them': 'THEY',
    'their': 'THEIR',
    'theirs': 'THEIR',
    'themselves': 'THEY',
    'this': 'THIS',
    'these': 'THIS',
    'those': 'THAT',
  };

  // ── Common Verbs ────────────────────────────────────────────
  static const _verbs = <String>{
    'go', 'goes', 'going', 'went', 'gone',
    'come', 'comes', 'coming', 'came',
    'want', 'wants', 'wanted', 'wanting',
    'need', 'needs', 'needed', 'needing',
    'like', 'likes', 'liked', 'liking',
    'love', 'loves', 'loved', 'loving',
    'help', 'helps', 'helped', 'helping',
    'eat', 'eats', 'eating', 'ate', 'eaten',
    'drink', 'drinks', 'drinking', 'drank', 'drunk',
    'sleep', 'sleeps', 'sleeping', 'slept',
    'work', 'works', 'working', 'worked',
    'study', 'studies', 'studying', 'studied',
    'play', 'plays', 'playing', 'played',
    'speak', 'speaks', 'speaking', 'spoke', 'spoken',
    'talk', 'talks', 'talking', 'talked',
    'listen', 'listens', 'listening', 'listened',
    'see', 'sees', 'seeing', 'saw', 'seen',
    'look', 'looks', 'looking', 'looked',
    'hear', 'hears', 'hearing', 'heard',
    'know', 'knows', 'knowing', 'knew', 'known',
    'think', 'thinks', 'thinking', 'thought',
    'feel', 'feels', 'feeling', 'felt',
    'give', 'gives', 'giving', 'gave', 'given',
    'take', 'takes', 'taking', 'took', 'taken',
    'make', 'makes', 'making', 'made',
    'learn', 'learns', 'learning', 'learned', 'learnt',
    'teach', 'teaches', 'teaching', 'taught',
    'read', 'reads', 'reading',
    'write', 'writes', 'writing', 'wrote', 'written',
    'sit', 'sits', 'sitting', 'sat',
    'stand', 'stands', 'standing', 'stood',
    'walk', 'walks', 'walking', 'walked',
    'run', 'runs', 'running', 'ran',
    'stop', 'stops', 'stopping', 'stopped',
    'wait', 'waits', 'waiting', 'waited',
    'call', 'calls', 'calling', 'called',
    'tell', 'tells', 'telling', 'told',
    'ask', 'asks', 'asking', 'asked',
    'say', 'says', 'saying', 'said',
    'try', 'tries', 'trying', 'tried',
    'use', 'uses', 'using', 'used',
    'find', 'finds', 'finding', 'found',
    'meet', 'meets', 'meeting', 'met',
    'live', 'lives', 'living', 'lived',
    'buy', 'buys', 'buying', 'bought',
    'pay', 'pays', 'paying', 'paid',
    'open', 'opens', 'opening', 'opened',
    'close', 'closes', 'closing', 'closed',
    'start', 'starts', 'starting', 'started',
    'finish', 'finishes', 'finishing', 'finished',
    'understand', 'understands', 'understanding', 'understood',
  };

  // ── Verb Root Mapping (inflected → base form) ──────────────
  static const _verbRoots = <String, String>{
    'goes': 'GO', 'going': 'GO', 'went': 'GO', 'gone': 'GO',
    'comes': 'COME', 'coming': 'COME', 'came': 'COME',
    'wants': 'WANT', 'wanted': 'WANT', 'wanting': 'WANT',
    'needs': 'NEED', 'needed': 'NEED', 'needing': 'NEED',
    'likes': 'LIKE', 'liked': 'LIKE', 'liking': 'LIKE',
    'loves': 'LOVE', 'loved': 'LOVE', 'loving': 'LOVE',
    'helps': 'HELP', 'helped': 'HELP', 'helping': 'HELP',
    'eats': 'EAT', 'eating': 'EAT', 'ate': 'EAT', 'eaten': 'EAT',
    'drinks': 'DRINK', 'drinking': 'DRINK', 'drank': 'DRINK', 'drunk': 'DRINK',
    'sleeps': 'SLEEP', 'sleeping': 'SLEEP', 'slept': 'SLEEP',
    'works': 'WORK', 'working': 'WORK', 'worked': 'WORK',
    'studies': 'STUDY', 'studying': 'STUDY', 'studied': 'STUDY',
    'plays': 'PLAY', 'playing': 'PLAY', 'played': 'PLAY',
    'speaks': 'SPEAK', 'speaking': 'SPEAK', 'spoke': 'SPEAK', 'spoken': 'SPEAK',
    'talks': 'TALK', 'talking': 'TALK', 'talked': 'TALK',
    'listens': 'LISTEN', 'listening': 'LISTEN', 'listened': 'LISTEN',
    'sees': 'SEE', 'seeing': 'SEE', 'saw': 'SEE', 'seen': 'SEE',
    'looks': 'LOOK', 'looking': 'LOOK', 'looked': 'LOOK',
    'hears': 'HEAR', 'hearing': 'HEAR', 'heard': 'HEAR',
    'knows': 'KNOW', 'knowing': 'KNOW', 'knew': 'KNOW', 'known': 'KNOW',
    'thinks': 'THINK', 'thinking': 'THINK', 'thought': 'THINK',
    'feels': 'FEEL', 'feeling': 'FEEL', 'felt': 'FEEL',
    'gives': 'GIVE', 'giving': 'GIVE', 'gave': 'GIVE', 'given': 'GIVE',
    'takes': 'TAKE', 'taking': 'TAKE', 'took': 'TAKE', 'taken': 'TAKE',
    'makes': 'MAKE', 'making': 'MAKE', 'made': 'MAKE',
    'learns': 'LEARN', 'learning': 'LEARN', 'learned': 'LEARN', 'learnt': 'LEARN',
    'teaches': 'TEACH', 'teaching': 'TEACH', 'taught': 'TEACH',
    'reads': 'READ', 'reading': 'READ',
    'writes': 'WRITE', 'writing': 'WRITE', 'wrote': 'WRITE', 'written': 'WRITE',
    'sits': 'SIT', 'sitting': 'SIT', 'sat': 'SIT',
    'stands': 'STAND', 'standing': 'STAND', 'stood': 'STAND',
    'walks': 'WALK', 'walking': 'WALK', 'walked': 'WALK',
    'runs': 'RUN', 'running': 'RUN', 'ran': 'RUN',
    'stops': 'STOP', 'stopping': 'STOP', 'stopped': 'STOP',
    'waits': 'WAIT', 'waiting': 'WAIT', 'waited': 'WAIT',
    'calls': 'CALL', 'calling': 'CALL', 'called': 'CALL',
    'tells': 'TELL', 'telling': 'TELL', 'told': 'TELL',
    'asks': 'ASK', 'asking': 'ASK', 'asked': 'ASK',
    'says': 'SAY', 'saying': 'SAY', 'said': 'SAY',
    'tries': 'TRY', 'trying': 'TRY', 'tried': 'TRY',
    'uses': 'USE', 'using': 'USE', 'used': 'USE',
    'finds': 'FIND', 'finding': 'FIND', 'found': 'FIND',
    'meets': 'MEET', 'meeting': 'MEET', 'met': 'MEET',
    'lives': 'LIVE', 'living': 'LIVE', 'lived': 'LIVE',
    'buys': 'BUY', 'buying': 'BUY', 'bought': 'BUY',
    'pays': 'PAY', 'paying': 'PAY', 'paid': 'PAY',
    'opens': 'OPEN', 'opening': 'OPEN', 'opened': 'OPEN',
    'closes': 'CLOSE', 'closing': 'CLOSE', 'closed': 'CLOSE',
    'starts': 'START', 'starting': 'START', 'started': 'START',
    'finishes': 'FINISH', 'finishing': 'FINISH', 'finished': 'FINISH',
    'understands': 'UNDERSTAND', 'understanding': 'UNDERSTAND', 'understood': 'UNDERSTAND',
  };

  // ── Question Words ─────────────────────────────────────────
  static const _questionWords = <String>{
    'what', 'where', 'when', 'who', 'whom', 'why', 'how',
    'which', 'whose',
  };

  // ── Negation Words ─────────────────────────────────────────
  static const _negationWords = <String>{
    'not', "don't", "doesn't", "didn't", "won't", "wouldn't",
    "can't", "cannot", "couldn't", "shouldn't", "haven't",
    "hasn't", "hadn't", 'never', 'no', "isn't", "aren't",
    "wasn't", "weren't",
  };

  // ── Common Adjectives ──────────────────────────────────────
  static const _adjectives = <String>{
    'good', 'bad', 'big', 'small', 'happy', 'sad', 'hot', 'cold',
    'new', 'old', 'beautiful', 'important', 'fast', 'slow',
    'tall', 'short', 'long', 'nice', 'fine', 'great',
    'hungry', 'thirsty', 'tired', 'sick', 'healthy', 'strong',
    'weak', 'easy', 'hard', 'difficult', 'correct', 'wrong',
    'same', 'different', 'many', 'few', 'much', 'little',
    'first', 'last', 'next', 'best', 'worst', 'better', 'worse',
  };

  // ── Number Words ───────────────────────────────────────────
  static const _numberWords = <String, String>{
    'one': 'ONE', 'two': 'TWO', 'three': 'THREE', 'four': 'FOUR',
    'five': 'FIVE', 'six': 'SIX', 'seven': 'SEVEN', 'eight': 'EIGHT',
    'nine': 'NINE', 'ten': 'TEN',
    'zero': 'ZERO', 'hundred': 'HUNDRED', 'thousand': 'THOUSAND',
  };

  // ── Greeting Words ─────────────────────────────────────────
  static const _greetingMap = <String, String>{
    'hello': 'HELLO',
    'hi': 'HELLO',
    'hey': 'HELLO',
    'goodbye': 'GOODBYE',
    'bye': 'GOODBYE',
    'thanks': 'THANK-YOU',
    'thank': 'THANK-YOU',
    'thankyou': 'THANK-YOU',
    'please': 'PLEASE',
    'sorry': 'SORRY',
    'welcome': 'WELCOME',
    'congratulations': 'CONGRATULATIONS',
    'congrats': 'CONGRATULATIONS',
  };

  /// Main glossing method.
  ///
  /// Takes English text and returns a list of [GlossToken] in ISL order.
  /// Stop words are included in the output (marked with [isStopWord])
  /// so the UI can show which words were removed.
  static GlossResult gloss(String text) {
    if (text.trim().isEmpty) {
      return const GlossResult(allTokens: [], activeTokens: []);
    }

    // 1. Tokenize
    final words = _tokenize(text);

    // 2. Tag and map each word
    final allTokens = <GlossToken>[];
    for (final word in words) {
      allTokens.add(_processWord(word));
    }

    // 3. Filter out stop words for the active ISL sequence
    final activeTokens = allTokens.where((t) => !t.isStopWord).toList();

    // 4. Reorder to ISL SOV grammar
    final reordered = _reorderSOV(activeTokens);

    return GlossResult(allTokens: allTokens, activeTokens: reordered);
  }

  /// Tokenizes text into individual words.
  static List<String> _tokenize(String text) {
    // Handle contractions
    var processed = text.toLowerCase().trim();
    processed = processed.replaceAll("don't", 'do not');
    processed = processed.replaceAll("doesn't", 'does not');
    processed = processed.replaceAll("didn't", 'did not');
    processed = processed.replaceAll("won't", 'will not');
    processed = processed.replaceAll("can't", 'can not');
    processed = processed.replaceAll("couldn't", 'could not');
    processed = processed.replaceAll("shouldn't", 'should not');
    processed = processed.replaceAll("wouldn't", 'would not');
    processed = processed.replaceAll("haven't", 'have not');
    processed = processed.replaceAll("hasn't", 'has not');
    processed = processed.replaceAll("isn't", 'is not');
    processed = processed.replaceAll("aren't", 'are not');
    processed = processed.replaceAll("wasn't", 'was not');
    processed = processed.replaceAll("weren't", 'were not');
    processed = processed.replaceAll("i'm", 'i am');
    processed = processed.replaceAll("i'll", 'i will');
    processed = processed.replaceAll("i've", 'i have');
    processed = processed.replaceAll("i'd", 'i would');
    processed = processed.replaceAll("he's", 'he is');
    processed = processed.replaceAll("she's", 'she is');
    processed = processed.replaceAll("it's", 'it is');
    processed = processed.replaceAll("we're", 'we are');
    processed = processed.replaceAll("they're", 'they are');
    processed = processed.replaceAll("you're", 'you are');
    processed = processed.replaceAll("we've", 'we have');
    processed = processed.replaceAll("they've", 'they have');
    processed = processed.replaceAll("you've", 'you have');
    processed = processed.replaceAll("let's", 'let us');

    // Remove punctuation except hyphens within words
    processed = processed.replaceAll(RegExp(r'[^\w\s-]'), '');

    // Split by whitespace
    return processed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  /// Processes a single word into a GlossToken.
  static GlossToken _processWord(String word) {
    final lower = word.toLowerCase();

    // Check greeting
    if (_greetingMap.containsKey(lower)) {
      return GlossToken(
        originalWord: word,
        glossForm: _greetingMap[lower]!,
        type: GlossTokenType.greeting,
      );
    }

    // Check question word
    if (_questionWords.contains(lower)) {
      return GlossToken(
        originalWord: word,
        glossForm: lower.toUpperCase(),
        type: GlossTokenType.question,
      );
    }

    // Check negation
    if (_negationWords.contains(lower)) {
      return GlossToken(
        originalWord: word,
        glossForm: 'NOT',
        type: GlossTokenType.negation,
      );
    }

    // Check stop word
    if (_stopWords.contains(lower)) {
      return GlossToken(
        originalWord: word,
        glossForm: lower.toUpperCase(),
        type: GlossTokenType.other,
        isStopWord: true,
      );
    }

    // Check pronoun
    if (_pronounMap.containsKey(lower)) {
      return GlossToken(
        originalWord: word,
        glossForm: _pronounMap[lower]!,
        type: GlossTokenType.pronoun,
      );
    }

    // Check number
    if (_numberWords.containsKey(lower)) {
      return GlossToken(
        originalWord: word,
        glossForm: _numberWords[lower]!,
        type: GlossTokenType.number,
      );
    }

    // Check verb (and get root form)
    if (_verbs.contains(lower)) {
      final root = _verbRoots[lower] ?? lower.toUpperCase();
      return GlossToken(
        originalWord: word,
        glossForm: root,
        type: GlossTokenType.verb,
      );
    }

    // Check adjective
    if (_adjectives.contains(lower)) {
      return GlossToken(
        originalWord: word,
        glossForm: lower.toUpperCase(),
        type: GlossTokenType.adjective,
      );
    }

    // Default: treat as noun
    return GlossToken(
      originalWord: word,
      glossForm: lower.toUpperCase(),
      type: GlossTokenType.noun,
    );
  }

  /// Reorders tokens to ISL SOV grammar.
  ///
  /// Order: Question words → Subjects (pronouns) → Objects (nouns/adj) → Verbs → Negation
  static List<GlossToken> _reorderSOV(List<GlossToken> tokens) {
    if (tokens.length <= 1) return tokens;

    final questions = <GlossToken>[];
    final pronouns = <GlossToken>[];
    final greetings = <GlossToken>[];
    final nouns = <GlossToken>[];
    final adjectives = <GlossToken>[];
    final numbers = <GlossToken>[];
    final verbs = <GlossToken>[];
    final negations = <GlossToken>[];
    final others = <GlossToken>[];

    for (final token in tokens) {
      switch (token.type) {
        case GlossTokenType.question:
          questions.add(token);
        case GlossTokenType.pronoun:
          pronouns.add(token);
        case GlossTokenType.greeting:
          greetings.add(token);
        case GlossTokenType.noun:
          nouns.add(token);
        case GlossTokenType.adjective:
          adjectives.add(token);
        case GlossTokenType.number:
          numbers.add(token);
        case GlossTokenType.verb:
          verbs.add(token);
        case GlossTokenType.negation:
          negations.add(token);
        case GlossTokenType.adverb:
        case GlossTokenType.other:
          others.add(token);
      }
    }

    // ISL order: Greetings → Questions → Subject → Object+Adj → Numbers → Verb → Negation → Others
    return [
      ...greetings,
      ...questions,
      ...pronouns,
      ...nouns,
      ...adjectives,
      ...numbers,
      ...verbs,
      ...negations,
      ...others,
    ];
  }

  /// Deduplicate consecutive identical glosses.
  /// e.g., "thank you" → THANK-YOU, THANK-YOU → THANK-YOU
  static List<GlossToken> deduplicate(List<GlossToken> tokens) {
    if (tokens.isEmpty) return tokens;
    final result = <GlossToken>[tokens.first];
    for (var i = 1; i < tokens.length; i++) {
      if (tokens[i].glossForm != tokens[i - 1].glossForm) {
        result.add(tokens[i]);
      }
    }
    return result;
  }
}

/// Result of glossing an English sentence.
class GlossResult {
  /// All tokens including stop words (for showing what was removed).
  final List<GlossToken> allTokens;

  /// Active tokens after stop-word removal and SOV reordering.
  final List<GlossToken> activeTokens;

  const GlossResult({
    required this.allTokens,
    required this.activeTokens,
  });

  /// The ISL gloss string (active tokens joined by spaces).
  String get glossString => activeTokens.map((t) => t.glossForm).join(' ');

  /// Whether the result is empty.
  bool get isEmpty => activeTokens.isEmpty;
}
