import 'package:flutter/material.dart';

import '../models/sign_entry.dart';
import '../../core/utils/isl_glosser.dart';

/// Repository for looking up ISL signs.
///
/// Contains a built-in dictionary of ~100 common ISL signs with
/// descriptions of how to perform each sign. Also handles
/// fingerspelling for words not found in the dictionary.
class SignDictionaryRepository {
  SignDictionaryRepository._();

  static final SignDictionaryRepository instance = SignDictionaryRepository._();

  /// Look up a gloss in the dictionary.
  SignEntry? lookup(String gloss) => _dictionary[gloss.toUpperCase()];

  /// Check if a gloss exists in the dictionary.
  bool has(String gloss) => _dictionary.containsKey(gloss.toUpperCase());

  /// Get a fingerspelling sign entry for a single letter.
  SignEntry fingerspellLetter(String letter) {
    final upper = letter.toUpperCase();
    return _alphabetSigns[upper] ?? SignEntry(
      gloss: upper,
      meaning: 'Letter $upper',
      category: SignCategory.fingerspell,
      description: 'Fingerspell the letter $upper using ISL hand shape.',
      icon: Icons.text_fields_rounded,
    );
  }

  /// Resolve a list of GlossTokens into SignPlaybackItems.
  ///
  /// For words found in the dictionary → use the dictionary sign.
  /// For words NOT found → fingerspell letter by letter.
  List<SignPlaybackItem> resolve(List<GlossToken> tokens) {
    final items = <SignPlaybackItem>[];
    final seen = <String>{};

    for (final token in tokens) {
      // Skip duplicates (already deduplicated by glosser)
      if (seen.contains(token.glossForm)) continue;
      seen.add(token.glossForm);

      final entry = lookup(token.glossForm);
      if (entry != null) {
        // Found in dictionary
        items.add(SignPlaybackItem(
          sign: entry,
          originalWord: token.originalWord,
        ));
      } else {
        // Fingerspell the word
        final word = token.glossForm;
        for (var i = 0; i < word.length; i++) {
          items.add(SignPlaybackItem(
            sign: fingerspellLetter(word[i]),
            originalWord: token.originalWord,
            isFingerspelled: true,
            parentWord: word,
            letterIndex: i,
            totalLetters: word.length,
          ));
        }
      }
    }

    return items;
  }

  // ════════════════════════════════════════════════════════════
  //  ISL FINGERSPELLING ALPHABET
  // ════════════════════════════════════════════════════════════

  static final Map<String, SignEntry> _alphabetSigns = {
    for (var i = 0; i < 26; i++)
      String.fromCharCode(65 + i): SignEntry(
        gloss: String.fromCharCode(65 + i),
        meaning: 'Letter ${String.fromCharCode(65 + i)}',
        category: SignCategory.fingerspell,
        description: _alphabetDescriptions[String.fromCharCode(65 + i)] ??
            'Form the ISL hand shape for ${String.fromCharCode(65 + i)}.',
        icon: Icons.front_hand_rounded,
      ),
  };

  static const Map<String, String> _alphabetDescriptions = {
    'A': 'Make a fist with thumb resting on the side of the index finger.',
    'B': 'Hold all four fingers straight up together, thumb tucked across palm.',
    'C': 'Curve fingers and thumb to form a C shape, like holding a cup.',
    'D': 'Touch thumb tip to middle, ring, and pinky fingertips. Index finger points up.',
    'E': 'Curl all fingers down, thumb tucked under fingertips.',
    'F': 'Touch index finger tip to thumb tip forming a circle. Other fingers spread up.',
    'G': 'Point index finger sideways, thumb parallel above it. Other fingers curled.',
    'H': 'Extend index and middle fingers together horizontally. Other fingers curled.',
    'I': 'Make a fist, extend only the pinky finger straight up.',
    'J': 'Start with I handshape (pinky up), trace a J in the air.',
    'K': 'Index and middle fingers up in a V, thumb between them touching middle finger.',
    'L': 'Extend thumb and index finger to form an L shape. Other fingers curled.',
    'M': 'Tuck thumb under the first three fingers (index, middle, ring) draped over.',
    'N': 'Tuck thumb under the first two fingers (index, middle) draped over.',
    'O': 'Curve all fingers and thumb to touch, forming an O shape.',
    'P': 'Like K but pointed downward — index and middle down, thumb between them.',
    'Q': 'Like G but pointed downward — index finger and thumb pointing down.',
    'R': 'Cross index and middle fingers. Other fingers curled, thumb tucked.',
    'S': 'Make a fist with thumb wrapped over the front of curled fingers.',
    'T': 'Tuck thumb between index and middle finger of a fist.',
    'U': 'Extend index and middle fingers together straight up. Other fingers curled.',
    'V': 'Extend index and middle fingers apart in a V. Other fingers curled.',
    'W': 'Extend index, middle, and ring fingers apart. Thumb holds pinky down.',
    'X': 'Hook index finger into a bent shape. Other fingers curled in a fist.',
    'Y': 'Extend thumb and pinky out. Other three fingers curled down.',
    'Z': 'Point index finger up, trace a Z in the air.',
  };

  // ════════════════════════════════════════════════════════════
  //  ISL SIGN DICTIONARY (~100 COMMON SIGNS)
  // ════════════════════════════════════════════════════════════

  static final Map<String, SignEntry> _dictionary = {
    // ── Greetings & Social ────────────────────────────────────
    'HELLO': const SignEntry(
      gloss: 'HELLO',
      meaning: 'Hello / Hi',
      category: SignCategory.greeting,
      description: 'Open palm facing outward near forehead, move it slightly forward like a friendly wave.',
      icon: Icons.waving_hand_rounded,
    ),
    'GOODBYE': const SignEntry(
      gloss: 'GOODBYE',
      meaning: 'Goodbye / Bye',
      category: SignCategory.greeting,
      description: 'Open palm facing outward, wave it side to side a few times.',
      icon: Icons.waving_hand_rounded,
    ),
    'THANK-YOU': const SignEntry(
      gloss: 'THANK-YOU',
      meaning: 'Thank you / Thanks',
      category: SignCategory.greeting,
      description: 'Touch fingertips to chin, then move hand forward and slightly down with palm up.',
      icon: Icons.favorite_rounded,
    ),
    'PLEASE': const SignEntry(
      gloss: 'PLEASE',
      meaning: 'Please',
      category: SignCategory.greeting,
      description: 'Place flat palm on chest and make a circular motion.',
      icon: Icons.volunteer_activism_rounded,
    ),
    'SORRY': const SignEntry(
      gloss: 'SORRY',
      meaning: 'Sorry / Apologize',
      category: SignCategory.greeting,
      description: 'Make a fist (A hand), circle it over the chest area.',
      icon: Icons.sentiment_dissatisfied_rounded,
    ),
    'WELCOME': const SignEntry(
      gloss: 'WELCOME',
      meaning: 'Welcome',
      category: SignCategory.greeting,
      description: 'Open hand sweeps inward toward the body in a welcoming gesture.',
      icon: Icons.door_front_door_rounded,
    ),
    'CONGRATULATIONS': const SignEntry(
      gloss: 'CONGRATULATIONS',
      meaning: 'Congratulations',
      category: SignCategory.greeting,
      description: 'Both hands clasped together, shake them slightly — like self-applause.',
      icon: Icons.celebration_rounded,
    ),
    'YES': const SignEntry(
      gloss: 'YES',
      meaning: 'Yes',
      category: SignCategory.greeting,
      description: 'Make a fist (S hand) and nod it up and down like a head nodding.',
      icon: Icons.check_circle_rounded,
    ),
    'NO': const SignEntry(
      gloss: 'NO',
      meaning: 'No',
      category: SignCategory.greeting,
      description: 'Extend index and middle fingers, snap them shut against thumb (like a beak closing).',
      icon: Icons.cancel_rounded,
    ),

    // ── Pronouns ──────────────────────────────────────────────
    'ME': const SignEntry(
      gloss: 'ME',
      meaning: 'I / Me',
      category: SignCategory.pronoun,
      description: 'Point index finger at your own chest.',
      icon: Icons.person_rounded,
    ),
    'YOU': const SignEntry(
      gloss: 'YOU',
      meaning: 'You',
      category: SignCategory.pronoun,
      description: 'Point index finger toward the other person.',
      icon: Icons.person_outline_rounded,
    ),
    'HE': const SignEntry(
      gloss: 'HE',
      meaning: 'He / Him',
      category: SignCategory.pronoun,
      description: 'Point index finger to the side (toward where the male person is or was referenced).',
      icon: Icons.man_rounded,
    ),
    'SHE': const SignEntry(
      gloss: 'SHE',
      meaning: 'She / Her',
      category: SignCategory.pronoun,
      description: 'Point index finger to the side (toward where the female person is or was referenced).',
      icon: Icons.woman_rounded,
    ),
    'WE': const SignEntry(
      gloss: 'WE',
      meaning: 'We / Us',
      category: SignCategory.pronoun,
      description: 'Point index finger at yourself, then sweep it in an arc to include others.',
      icon: Icons.groups_rounded,
    ),
    'THEY': const SignEntry(
      gloss: 'THEY',
      meaning: 'They / Them',
      category: SignCategory.pronoun,
      description: 'Point index finger and sweep it across to indicate a group of people.',
      icon: Icons.groups_rounded,
    ),
    'MY': const SignEntry(
      gloss: 'MY',
      meaning: 'My / Mine',
      category: SignCategory.pronoun,
      description: 'Place flat open palm on your chest.',
      icon: Icons.person_rounded,
    ),
    'YOUR': const SignEntry(
      gloss: 'YOUR',
      meaning: 'Your / Yours',
      category: SignCategory.pronoun,
      description: 'Push flat open palm toward the other person.',
      icon: Icons.person_outline_rounded,
    ),
    'HIS': const SignEntry(
      gloss: 'HIS',
      meaning: 'His',
      category: SignCategory.pronoun,
      description: 'Push flat palm toward the side where the male was referenced.',
      icon: Icons.man_rounded,
    ),
    'HER': const SignEntry(
      gloss: 'HER',
      meaning: 'Her / Hers',
      category: SignCategory.pronoun,
      description: 'Push flat palm toward the side where the female was referenced.',
      icon: Icons.woman_rounded,
    ),
    'OUR': const SignEntry(
      gloss: 'OUR',
      meaning: 'Our / Ours',
      category: SignCategory.pronoun,
      description: 'Touch flat palm to one side of chest, arc it to the other side.',
      icon: Icons.groups_rounded,
    ),
    'THEIR': const SignEntry(
      gloss: 'THEIR',
      meaning: 'Their / Theirs',
      category: SignCategory.pronoun,
      description: 'Push flat palm outward and sweep across to indicate the group\'s possession.',
      icon: Icons.groups_rounded,
    ),
    'THIS': const SignEntry(
      gloss: 'THIS',
      meaning: 'This / These',
      category: SignCategory.pronoun,
      description: 'Point index finger downward at the item being referenced.',
      icon: Icons.touch_app_rounded,
    ),
    'THAT': const SignEntry(
      gloss: 'THAT',
      meaning: 'That / Those',
      category: SignCategory.pronoun,
      description: 'Point index finger outward/away at the item being referenced.',
      icon: Icons.near_me_rounded,
    ),

    // ── Common Verbs ──────────────────────────────────────────
    'GO': const SignEntry(
      gloss: 'GO',
      meaning: 'Go / Leave',
      category: SignCategory.verb,
      description: 'Both index fingers point forward, move them away from body simultaneously.',
      icon: Icons.directions_walk_rounded,
    ),
    'COME': const SignEntry(
      gloss: 'COME',
      meaning: 'Come',
      category: SignCategory.verb,
      description: 'Both index fingers pointing outward, bring them toward your body.',
      icon: Icons.arrow_back_rounded,
    ),
    'WANT': const SignEntry(
      gloss: 'WANT',
      meaning: 'Want / Desire',
      category: SignCategory.verb,
      description: 'Both hands open with palms up, pull them toward yourself with fingers curling in.',
      icon: Icons.front_hand_rounded,
    ),
    'NEED': const SignEntry(
      gloss: 'NEED',
      meaning: 'Need / Must',
      category: SignCategory.verb,
      description: 'Bent index finger (X hand) moves downward firmly — like a nod of necessity.',
      icon: Icons.priority_high_rounded,
    ),
    'LIKE': const SignEntry(
      gloss: 'LIKE',
      meaning: 'Like / Enjoy',
      category: SignCategory.verb,
      description: 'Place thumb and middle finger on chest, pull away while pinching together.',
      icon: Icons.thumb_up_rounded,
    ),
    'LOVE': const SignEntry(
      gloss: 'LOVE',
      meaning: 'Love',
      category: SignCategory.verb,
      description: 'Cross both fists over your heart/chest area, like giving yourself a hug.',
      icon: Icons.favorite_rounded,
    ),
    'HELP': const SignEntry(
      gloss: 'HELP',
      meaning: 'Help / Assist',
      category: SignCategory.verb,
      description: 'Place fist (A hand) on open flat palm; lift both hands upward together.',
      icon: Icons.handshake_rounded,
    ),
    'EAT': const SignEntry(
      gloss: 'EAT',
      meaning: 'Eat / Food',
      category: SignCategory.verb,
      description: 'Bring flattened O hand (fingertips together) toward mouth repeatedly.',
      icon: Icons.restaurant_rounded,
    ),
    'DRINK': const SignEntry(
      gloss: 'DRINK',
      meaning: 'Drink',
      category: SignCategory.verb,
      description: 'Mime holding a cup (C hand) and tilt it toward your mouth.',
      icon: Icons.local_drink_rounded,
    ),
    'SLEEP': const SignEntry(
      gloss: 'SLEEP',
      meaning: 'Sleep',
      category: SignCategory.verb,
      description: 'Place open hand over face, slowly close fingers while tilting head slightly.',
      icon: Icons.bedtime_rounded,
    ),
    'WORK': const SignEntry(
      gloss: 'WORK',
      meaning: 'Work / Job',
      category: SignCategory.verb,
      description: 'Both fists (S hands), tap the wrist of one on top of the other repeatedly.',
      icon: Icons.work_rounded,
    ),
    'STUDY': const SignEntry(
      gloss: 'STUDY',
      meaning: 'Study / Learn',
      category: SignCategory.verb,
      description: 'Open hand faces open palm (like a book), wiggle fingers on the "book" hand.',
      icon: Icons.menu_book_rounded,
    ),
    'PLAY': const SignEntry(
      gloss: 'PLAY',
      meaning: 'Play',
      category: SignCategory.verb,
      description: 'Both Y hands (thumb and pinky out), shake them back and forth playfully.',
      icon: Icons.sports_esports_rounded,
    ),
    'SPEAK': const SignEntry(
      gloss: 'SPEAK',
      meaning: 'Speak / Talk / Say',
      category: SignCategory.verb,
      description: 'Tap index finger on chin/lips, then move it forward — words coming from mouth.',
      icon: Icons.record_voice_over_rounded,
    ),
    'TALK': const SignEntry(
      gloss: 'TALK',
      meaning: 'Talk / Converse',
      category: SignCategory.verb,
      description: 'Both index fingers point at each other near the mouth, alternate back and forth.',
      icon: Icons.chat_rounded,
    ),
    'LISTEN': const SignEntry(
      gloss: 'LISTEN',
      meaning: 'Listen / Hear',
      category: SignCategory.verb,
      description: 'Cup hand behind ear and lean slightly forward.',
      icon: Icons.hearing_rounded,
    ),
    'SEE': const SignEntry(
      gloss: 'SEE',
      meaning: 'See / Look / Watch',
      category: SignCategory.verb,
      description: 'Point V fingers (index + middle) from your eyes outward — "eyes looking".',
      icon: Icons.visibility_rounded,
    ),
    'LOOK': const SignEntry(
      gloss: 'LOOK',
      meaning: 'Look / Watch',
      category: SignCategory.verb,
      description: 'V hand from eyes, direct outward toward what you\'re looking at.',
      icon: Icons.visibility_rounded,
    ),
    'HEAR': const SignEntry(
      gloss: 'HEAR',
      meaning: 'Hear',
      category: SignCategory.verb,
      description: 'Point index finger toward your ear.',
      icon: Icons.hearing_rounded,
    ),
    'KNOW': const SignEntry(
      gloss: 'KNOW',
      meaning: 'Know / Knowledge',
      category: SignCategory.verb,
      description: 'Tap fingertips on forehead/temple area — indicating something is in the mind.',
      icon: Icons.lightbulb_rounded,
    ),
    'THINK': const SignEntry(
      gloss: 'THINK',
      meaning: 'Think',
      category: SignCategory.verb,
      description: 'Point index finger to forehead and make a small circular motion.',
      icon: Icons.psychology_rounded,
    ),
    'FEEL': const SignEntry(
      gloss: 'FEEL',
      meaning: 'Feel / Emotion',
      category: SignCategory.verb,
      description: 'Middle finger touches chest and brushes upward — feeling rising from the heart.',
      icon: Icons.sentiment_satisfied_rounded,
    ),
    'GIVE': const SignEntry(
      gloss: 'GIVE',
      meaning: 'Give',
      category: SignCategory.verb,
      description: 'Flattened O hand moves forward from your body, opening as it extends outward.',
      icon: Icons.card_giftcard_rounded,
    ),
    'TAKE': const SignEntry(
      gloss: 'TAKE',
      meaning: 'Take / Get',
      category: SignCategory.verb,
      description: 'Open hand reaches outward, then pulls back toward body while closing into a fist.',
      icon: Icons.back_hand_rounded,
    ),
    'MAKE': const SignEntry(
      gloss: 'MAKE',
      meaning: 'Make / Create',
      category: SignCategory.verb,
      description: 'Both fists stack and twist on top of each other — like molding something.',
      icon: Icons.construction_rounded,
    ),
    'LEARN': const SignEntry(
      gloss: 'LEARN',
      meaning: 'Learn',
      category: SignCategory.verb,
      description: 'Pick up knowledge from open palm (book) and place fingertips on forehead.',
      icon: Icons.school_rounded,
    ),
    'TEACH': const SignEntry(
      gloss: 'TEACH',
      meaning: 'Teach / Instruct',
      category: SignCategory.verb,
      description: 'Both flattened O hands at temples, move them forward and open — sharing knowledge.',
      icon: Icons.cast_for_education_rounded,
    ),
    'READ': const SignEntry(
      gloss: 'READ',
      meaning: 'Read',
      category: SignCategory.verb,
      description: 'V hand (two fingers) scans across open palm — like eyes scanning a page.',
      icon: Icons.auto_stories_rounded,
    ),
    'WRITE': const SignEntry(
      gloss: 'WRITE',
      meaning: 'Write',
      category: SignCategory.verb,
      description: 'Mime holding a pen, make writing motions on open palm.',
      icon: Icons.edit_rounded,
    ),
    'SIT': const SignEntry(
      gloss: 'SIT',
      meaning: 'Sit / Sit down',
      category: SignCategory.verb,
      description: 'Two curved fingers (like legs) sit on top of two straight fingers of other hand.',
      icon: Icons.chair_rounded,
    ),
    'STAND': const SignEntry(
      gloss: 'STAND',
      meaning: 'Stand / Stand up',
      category: SignCategory.verb,
      description: 'Two straight fingers stand upright on flat open palm.',
      icon: Icons.accessibility_new_rounded,
    ),
    'WALK': const SignEntry(
      gloss: 'WALK',
      meaning: 'Walk',
      category: SignCategory.verb,
      description: 'Both flat hands alternate moving forward like feet walking.',
      icon: Icons.directions_walk_rounded,
    ),
    'RUN': const SignEntry(
      gloss: 'RUN',
      meaning: 'Run',
      category: SignCategory.verb,
      description: 'L hands (index + thumb), hook index of one on thumb of other, move quickly forward.',
      icon: Icons.directions_run_rounded,
    ),
    'STOP': const SignEntry(
      gloss: 'STOP',
      meaning: 'Stop',
      category: SignCategory.verb,
      description: 'One flat hand chops down onto the open palm of the other hand.',
      icon: Icons.pan_tool_rounded,
    ),
    'WAIT': const SignEntry(
      gloss: 'WAIT',
      meaning: 'Wait',
      category: SignCategory.verb,
      description: 'Both open hands face up, wiggle fingers slightly — showing patience.',
      icon: Icons.hourglass_top_rounded,
    ),
    'UNDERSTAND': const SignEntry(
      gloss: 'UNDERSTAND',
      meaning: 'Understand',
      category: SignCategory.verb,
      description: 'Index finger near forehead flicks upward — like a lightbulb turning on.',
      icon: Icons.lightbulb_rounded,
    ),
    'CALL': const SignEntry(
      gloss: 'CALL',
      meaning: 'Call / Phone',
      category: SignCategory.verb,
      description: 'Y hand (thumb + pinky) held near ear like a phone.',
      icon: Icons.phone_rounded,
    ),
    'ASK': const SignEntry(
      gloss: 'ASK',
      meaning: 'Ask / Question',
      category: SignCategory.verb,
      description: 'Draw a question mark in the air with index finger.',
      icon: Icons.help_rounded,
    ),
    'TRY': const SignEntry(
      gloss: 'TRY',
      meaning: 'Try / Attempt',
      category: SignCategory.verb,
      description: 'Both fists push forward together with effort — trying to accomplish.',
      icon: Icons.fitness_center_rounded,
    ),
    'FIND': const SignEntry(
      gloss: 'FIND',
      meaning: 'Find / Discover',
      category: SignCategory.verb,
      description: 'Open hand reaches down, picks something up between thumb and index finger.',
      icon: Icons.search_rounded,
    ),
    'MEET': const SignEntry(
      gloss: 'MEET',
      meaning: 'Meet',
      category: SignCategory.verb,
      description: 'Both index fingers (representing people) approach each other and meet.',
      icon: Icons.handshake_rounded,
    ),
    'BUY': const SignEntry(
      gloss: 'BUY',
      meaning: 'Buy / Purchase',
      category: SignCategory.verb,
      description: 'Flat hand on open palm lifts up and moves forward — money leaving your hand.',
      icon: Icons.shopping_cart_rounded,
    ),
    'FINISH': const SignEntry(
      gloss: 'FINISH',
      meaning: 'Finish / Done / Complete',
      category: SignCategory.verb,
      description: 'Both open hands (5 hands) flip outward simultaneously — all done.',
      icon: Icons.done_all_rounded,
    ),

    // ── Common Nouns ──────────────────────────────────────────
    'SCHOOL': const SignEntry(
      gloss: 'SCHOOL',
      meaning: 'School',
      category: SignCategory.noun,
      description: 'Clap hands together twice — like a teacher clapping for attention.',
      icon: Icons.school_rounded,
    ),
    'HOME': const SignEntry(
      gloss: 'HOME',
      meaning: 'Home / House',
      category: SignCategory.noun,
      description: 'Touch fingertips together forming a roof shape above your head.',
      icon: Icons.home_rounded,
    ),
    'FAMILY': const SignEntry(
      gloss: 'FAMILY',
      meaning: 'Family',
      category: SignCategory.noun,
      description: 'Both F hands make a circle in front of body — a family circle.',
      icon: Icons.family_restroom_rounded,
    ),
    'MOTHER': const SignEntry(
      gloss: 'MOTHER',
      meaning: 'Mother / Mom',
      category: SignCategory.noun,
      description: 'Open hand with thumb touching chin — female sign at chin level.',
      icon: Icons.woman_rounded,
    ),
    'FATHER': const SignEntry(
      gloss: 'FATHER',
      meaning: 'Father / Dad',
      category: SignCategory.noun,
      description: 'Open hand with thumb touching forehead — male sign at forehead level.',
      icon: Icons.man_rounded,
    ),
    'BROTHER': const SignEntry(
      gloss: 'BROTHER',
      meaning: 'Brother',
      category: SignCategory.noun,
      description: 'Male sign (thumb on forehead), then both index fingers come together side by side.',
      icon: Icons.man_rounded,
    ),
    'SISTER': const SignEntry(
      gloss: 'SISTER',
      meaning: 'Sister',
      category: SignCategory.noun,
      description: 'Female sign (thumb on chin), then both index fingers come together side by side.',
      icon: Icons.woman_rounded,
    ),
    'FRIEND': const SignEntry(
      gloss: 'FRIEND',
      meaning: 'Friend',
      category: SignCategory.noun,
      description: 'Hook index fingers together (like linked chains) and rotate.',
      icon: Icons.people_rounded,
    ),
    'TEACHER': const SignEntry(
      gloss: 'TEACHER',
      meaning: 'Teacher',
      category: SignCategory.noun,
      description: 'Both flat O hands at temples move forward (TEACH), then flat hands move down (PERSON).',
      icon: Icons.cast_for_education_rounded,
    ),
    'STUDENT': const SignEntry(
      gloss: 'STUDENT',
      meaning: 'Student',
      category: SignCategory.noun,
      description: 'Pick up from palm to forehead (LEARN), then flat hands move down (PERSON).',
      icon: Icons.school_rounded,
    ),
    'BOOK': const SignEntry(
      gloss: 'BOOK',
      meaning: 'Book',
      category: SignCategory.noun,
      description: 'Both flat palms together, open them like opening a book.',
      icon: Icons.menu_book_rounded,
    ),
    'WATER': const SignEntry(
      gloss: 'WATER',
      meaning: 'Water',
      category: SignCategory.noun,
      description: 'W hand (three fingers up) taps chin twice.',
      icon: Icons.water_drop_rounded,
    ),
    'FOOD': const SignEntry(
      gloss: 'FOOD',
      meaning: 'Food / Eat',
      category: SignCategory.noun,
      description: 'Flattened O hand moves toward mouth — putting food in mouth.',
      icon: Icons.fastfood_rounded,
    ),
    'NAME': const SignEntry(
      gloss: 'NAME',
      meaning: 'Name',
      category: SignCategory.noun,
      description: 'H hand (two fingers extended) tap on top of other H hand twice in a cross shape.',
      icon: Icons.badge_rounded,
    ),
    'TIME': const SignEntry(
      gloss: 'TIME',
      meaning: 'Time',
      category: SignCategory.noun,
      description: 'Tap the wrist (where a watch would be) with the index finger.',
      icon: Icons.access_time_rounded,
    ),
    'DAY': const SignEntry(
      gloss: 'DAY',
      meaning: 'Day',
      category: SignCategory.noun,
      description: 'Rest elbow on back of other hand, move pointing index in an arc like the sun\'s path.',
      icon: Icons.wb_sunny_rounded,
    ),
    'PHONE': const SignEntry(
      gloss: 'PHONE',
      meaning: 'Phone / Telephone',
      category: SignCategory.noun,
      description: 'Y hand (thumb + pinky out) held to ear like holding a phone.',
      icon: Icons.phone_rounded,
    ),
    'DOCTOR': const SignEntry(
      gloss: 'DOCTOR',
      meaning: 'Doctor',
      category: SignCategory.noun,
      description: 'Tap fingertips (like taking pulse) on the inner wrist of the other hand.',
      icon: Icons.medical_services_rounded,
    ),
    'MONEY': const SignEntry(
      gloss: 'MONEY',
      meaning: 'Money',
      category: SignCategory.noun,
      description: 'Tap the back of one flat hand on the open palm of the other — like patting a wallet.',
      icon: Icons.attach_money_rounded,
    ),
    'HOSPITAL': const SignEntry(
      gloss: 'HOSPITAL',
      meaning: 'Hospital',
      category: SignCategory.noun,
      description: 'Draw a cross (+) on the upper arm with the index finger (like a medical cross).',
      icon: Icons.local_hospital_rounded,
    ),
    'LANGUAGE': const SignEntry(
      gloss: 'LANGUAGE',
      meaning: 'Language',
      category: SignCategory.noun,
      description: 'Both L hands move apart from center in wavy motions — language flowing.',
      icon: Icons.translate_rounded,
    ),
    'SIGN': const SignEntry(
      gloss: 'SIGN',
      meaning: 'Sign Language',
      category: SignCategory.noun,
      description: 'Both index fingers rotate alternately in circles — representing signing.',
      icon: Icons.sign_language_rounded,
    ),

    // ── Adjectives ────────────────────────────────────────────
    'GOOD': const SignEntry(
      gloss: 'GOOD',
      meaning: 'Good',
      category: SignCategory.adjective,
      description: 'Touch flat hand to chin/lips, then move it forward and down onto the other open palm.',
      icon: Icons.thumb_up_rounded,
    ),
    'BAD': const SignEntry(
      gloss: 'BAD',
      meaning: 'Bad',
      category: SignCategory.adjective,
      description: 'Touch flat hand to chin, then flip it over and move down — opposite of GOOD.',
      icon: Icons.thumb_down_rounded,
    ),
    'BIG': const SignEntry(
      gloss: 'BIG',
      meaning: 'Big / Large',
      category: SignCategory.adjective,
      description: 'Both hands with L shape, move them apart from each other — showing size.',
      icon: Icons.open_in_full_rounded,
    ),
    'SMALL': const SignEntry(
      gloss: 'SMALL',
      meaning: 'Small / Little',
      category: SignCategory.adjective,
      description: 'Both flat hands face each other, bring them closer together — showing smallness.',
      icon: Icons.close_fullscreen_rounded,
    ),
    'HAPPY': const SignEntry(
      gloss: 'HAPPY',
      meaning: 'Happy / Glad',
      category: SignCategory.adjective,
      description: 'Both flat hands brush upward on the chest repeatedly — happiness rising.',
      icon: Icons.sentiment_very_satisfied_rounded,
    ),
    'SAD': const SignEntry(
      gloss: 'SAD',
      meaning: 'Sad / Unhappy',
      category: SignCategory.adjective,
      description: 'Both open hands slide down the face — tears falling.',
      icon: Icons.sentiment_very_dissatisfied_rounded,
    ),
    'HOT': const SignEntry(
      gloss: 'HOT',
      meaning: 'Hot',
      category: SignCategory.adjective,
      description: 'Claw hand near mouth, twist it away quickly — like spitting out hot food.',
      icon: Icons.whatshot_rounded,
    ),
    'COLD': const SignEntry(
      gloss: 'COLD',
      meaning: 'Cold',
      category: SignCategory.adjective,
      description: 'Both fists close to body, shiver/shake them — showing cold.',
      icon: Icons.ac_unit_rounded,
    ),
    'NEW': const SignEntry(
      gloss: 'NEW',
      meaning: 'New',
      category: SignCategory.adjective,
      description: 'Curved hand scoops across the open palm — something fresh appearing.',
      icon: Icons.fiber_new_rounded,
    ),
    'OLD': const SignEntry(
      gloss: 'OLD',
      meaning: 'Old',
      category: SignCategory.adjective,
      description: 'S hand at chin moves downward in a wavy motion — like a long beard.',
      icon: Icons.elderly_rounded,
    ),
    'BEAUTIFUL': const SignEntry(
      gloss: 'BEAUTIFUL',
      meaning: 'Beautiful / Pretty',
      category: SignCategory.adjective,
      description: 'Open hand circles the face, then closes into a flat O — beauty radiating.',
      icon: Icons.auto_awesome_rounded,
    ),
    'IMPORTANT': const SignEntry(
      gloss: 'IMPORTANT',
      meaning: 'Important',
      category: SignCategory.adjective,
      description: 'Both F hands come up from below and meet at the center top — elevating importance.',
      icon: Icons.star_rounded,
    ),
    'HUNGRY': const SignEntry(
      gloss: 'HUNGRY',
      meaning: 'Hungry',
      category: SignCategory.adjective,
      description: 'C hand slides down from throat to stomach — hunger feeling.',
      icon: Icons.restaurant_rounded,
    ),
    'TIRED': const SignEntry(
      gloss: 'TIRED',
      meaning: 'Tired / Exhausted',
      category: SignCategory.adjective,
      description: 'Both bent hands on chest, let them droop/fall — energy draining.',
      icon: Icons.battery_alert_rounded,
    ),
    'SICK': const SignEntry(
      gloss: 'SICK',
      meaning: 'Sick / Ill',
      category: SignCategory.adjective,
      description: 'Middle finger touches forehead, other middle finger touches stomach — feeling unwell.',
      icon: Icons.sick_rounded,
    ),

    // ── Question Words ────────────────────────────────────────
    'WHAT': const SignEntry(
      gloss: 'WHAT',
      meaning: 'What',
      category: SignCategory.question,
      description: 'Hold out both open palms, shake them slightly side to side with questioning face.',
      icon: Icons.help_rounded,
    ),
    'WHERE': const SignEntry(
      gloss: 'WHERE',
      meaning: 'Where',
      category: SignCategory.question,
      description: 'Wave index finger side to side with a questioning expression.',
      icon: Icons.place_rounded,
    ),
    'WHEN': const SignEntry(
      gloss: 'WHEN',
      meaning: 'When',
      category: SignCategory.question,
      description: 'Point index finger, circle it around the other pointing index finger, then touch tips.',
      icon: Icons.schedule_rounded,
    ),
    'WHO': const SignEntry(
      gloss: 'WHO',
      meaning: 'Who',
      category: SignCategory.question,
      description: 'Circle index finger around the mouth area with a questioning look.',
      icon: Icons.person_search_rounded,
    ),
    'WHY': const SignEntry(
      gloss: 'WHY',
      meaning: 'Why',
      category: SignCategory.question,
      description: 'Touch forehead with fingertips, then pull away into Y hand — "what\'s in the mind?"',
      icon: Icons.quiz_rounded,
    ),
    'HOW': const SignEntry(
      gloss: 'HOW',
      meaning: 'How',
      category: SignCategory.question,
      description: 'Both bent hands (palms down) roll forward and open up — showing the process.',
      icon: Icons.build_rounded,
    ),

    // ── Numbers ───────────────────────────────────────────────
    'ONE': const SignEntry(
      gloss: 'ONE',
      meaning: '1',
      category: SignCategory.number,
      description: 'Hold up index finger.',
      icon: Icons.looks_one_rounded,
    ),
    'TWO': const SignEntry(
      gloss: 'TWO',
      meaning: '2',
      category: SignCategory.number,
      description: 'Hold up index and middle fingers in a V shape.',
      icon: Icons.looks_two_rounded,
    ),
    'THREE': const SignEntry(
      gloss: 'THREE',
      meaning: '3',
      category: SignCategory.number,
      description: 'Hold up index, middle, and ring fingers.',
      icon: Icons.looks_3_rounded,
    ),
    'FOUR': const SignEntry(
      gloss: 'FOUR',
      meaning: '4',
      category: SignCategory.number,
      description: 'Hold up all four fingers (index through pinky), thumb tucked.',
      icon: Icons.looks_4_rounded,
    ),
    'FIVE': const SignEntry(
      gloss: 'FIVE',
      meaning: '5',
      category: SignCategory.number,
      description: 'Hold up all five fingers, palm facing outward.',
      icon: Icons.looks_5_rounded,
    ),

    // ── Negation ──────────────────────────────────────────────
    'NOT': const SignEntry(
      gloss: 'NOT',
      meaning: 'Not / No / Negative',
      category: SignCategory.negation,
      description: 'Thumb under chin flicks forward — negating the statement.',
      icon: Icons.do_not_disturb_on_rounded,
    ),

    // ── Other Common Words ────────────────────────────────────
    'MORE': const SignEntry(
      gloss: 'MORE',
      meaning: 'More',
      category: SignCategory.other,
      description: 'Both flattened O hands tap fingertips together repeatedly.',
      icon: Icons.add_rounded,
    ),
    'AGAIN': const SignEntry(
      gloss: 'AGAIN',
      meaning: 'Again / Repeat',
      category: SignCategory.other,
      description: 'Bent hand flips onto the open palm — doing it again.',
      icon: Icons.replay_rounded,
    ),
    'DONE': const SignEntry(
      gloss: 'DONE',
      meaning: 'Done / Finished',
      category: SignCategory.other,
      description: 'Both open hands (5 hands) flip outward simultaneously — all done.',
      icon: Icons.done_rounded,
    ),
  };
}
