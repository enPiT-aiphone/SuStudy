import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadWordsToFirestore_idiom() async {
  final firestore = FirebaseFirestore.instance;
  const collectionPath = 'English_Skills/TOEIC/up_to_500/Words/Idioms';

  // 登録するデータ
  final List<Map<String, dynamic>> wordsData = [
    {
    "Idiom": "break the ice",
    "Explanation": "初対面の人との緊張を和らげる行動や言葉",
    "Question": "The host told a joke to _________ at the party.",
    "Question_JPN": "ホストはパーティーで雰囲気を和らげるために冗談を言いました。",
    "Answer": "break the ice",
    "Answer_A": "break the ice",
    "Answer_B": "spill the beans",
    "Answer_C": "hit the sack",
    "Answer_D": "bite the bullet",
    "JPN_Answer": "緊張をほぐす",
    "JPN_Answer_A": "緊張をほぐす",
    "JPN_Answer_B": "秘密を漏らす",
    "JPN_Answer_C": "寝る",
    "JPN_Answer_D": "決心する",
    "Phonetic_Symbols": "/breɪk ði aɪs/",
    "Word_Synonyms": "ease the tension, lighten the mood"
  },
  {
    "Idiom": "spill the beans",
    "Explanation": "秘密を漏らす",
    "Question": "Someone accidentally _________ about the surprise party.",
    "Question_JPN": "誰かが誤ってサプライズパーティーについて話してしまいました。",
    "Answer": "spill the beans",
    "Answer_A": "spill the beans",
    "Answer_B": "break the ice",
    "Answer_C": "hit the sack",
    "Answer_D": "bite the bullet",
    "JPN_Answer": "秘密を漏らす",
    "JPN_Answer_A": "秘密を漏らす",
    "JPN_Answer_B": "緊張をほぐす",
    "JPN_Answer_C": "寝る",
    "JPN_Answer_D": "決心する",
    "Phonetic_Symbols": "/spɪl ðə biːnz/",
    "Word_Synonyms": "reveal a secret, let the cat out of the bag"
  },
  {
    "Idiom": "hit the sack",
    "Explanation": "寝る",
    "Question": "After a long day, she decided to _________.",
    "Question_JPN": "長い一日の後、彼女は寝ることにしました。",
    "Answer": "hit the sack",
    "Answer_A": "hit the sack",
    "Answer_B": "spill the beans",
    "Answer_C": "break the ice",
    "Answer_D": "bite the bullet",
    "JPN_Answer": "寝る",
    "JPN_Answer_A": "寝る",
    "JPN_Answer_B": "秘密を漏らす",
    "JPN_Answer_C": "緊張をほぐす",
    "JPN_Answer_D": "決心する",
    "Phonetic_Symbols": "/hɪt ðə sæk/",
    "Word_Synonyms": "go to bed, retire for the night"
  },
  {
    "Idiom": "bite the bullet",
    "Explanation": "困難を覚悟する",
    "Question": "He had to _________ and take the exam.",
    "Question_JPN": "彼は覚悟を決めて試験を受けなければなりませんでした。",
    "Answer": "bite the bullet",
    "Answer_A": "bite the bullet",
    "Answer_B": "spill the beans",
    "Answer_C": "break the ice",
    "Answer_D": "hit the sack",
    "JPN_Answer": "困難を覚悟する",
    "JPN_Answer_A": "困難を覚悟する",
    "JPN_Answer_B": "秘密を漏らす",
    "JPN_Answer_C": "緊張をほぐす",
    "JPN_Answer_D": "寝る",
    "Phonetic_Symbols": "/baɪt ðə ˈbʊlɪt/",
    "Word_Synonyms": "face the challenge, endure"
  },
  {
    "Idiom": "on cloud nine",
    "Explanation": "とても幸せである",
    "Question": "She was _________ after getting the promotion.",
    "Question_JPN": "彼女は昇進が決まってとても幸せでした。",
    "Answer": "on cloud nine",
    "Answer_A": "on cloud nine",
    "Answer_B": "under the weather",
    "Answer_C": "in hot water",
    "Answer_D": "break the ice",
    "JPN_Answer": "とても幸せである",
    "JPN_Answer_A": "とても幸せである",
    "JPN_Answer_B": "体調が悪い",
    "JPN_Answer_C": "困難に陥っている",
    "JPN_Answer_D": "緊張をほぐす",
    "Phonetic_Symbols": "/ɒn klaʊd naɪn/",
    "Word_Synonyms": "very happy, over the moon"
  },
  {
    "Idiom": "under the weather",
    "Explanation": "体調が悪い",
    "Question": "I couldn't go to work yesterday because I was feeling _________.",
    "Question_JPN": "昨日、体調が悪かったので仕事に行けませんでした。",
    "Answer": "under the weather",
    "Answer_A": "under the weather",
    "Answer_B": "in hot water",
    "Answer_C": "on the ball",
    "Answer_D": "over the moon",
    "JPN_Answer": "体調が悪い",
    "JPN_Answer_A": "体調が悪い",
    "JPN_Answer_B": "困難に陥っている",
    "JPN_Answer_C": "よく気がつく",
    "JPN_Answer_D": "とても幸せである",
    "Phonetic_Symbols": "/ˈʌndər ðə ˈwɛðər/",
    "Word_Synonyms": "ill, unwell"
  },
  {
    "Idiom": "in hot water",
    "Explanation": "困難な状況にいる",
    "Question": "He found himself _________ after missing the deadline.",
    "Question_JPN": "彼は締め切りを逃して困難な状況に陥りました。",
    "Answer": "in hot water",
    "Answer_A": "in hot water",
    "Answer_B": "hit the books",
    "Answer_C": "let the cat out of the bag",
    "Answer_D": "break the ice",
    "JPN_Answer": "困難な状況にいる",
    "JPN_Answer_A": "困難な状況にいる",
    "JPN_Answer_B": "勉強する",
    "JPN_Answer_C": "秘密を漏らす",
    "JPN_Answer_D": "緊張をほぐす",
    "Phonetic_Symbols": "/ɪn hɒt ˈwɔːtər/",
    "Word_Synonyms": "in trouble, in a difficult situation"
  },
  {
    "Idiom": "hit the books",
    "Explanation": "勉強をする",
    "Question": "I need to _________ if I want to pass the exam tomorrow.",
    "Question_JPN": "明日の試験に合格したいなら、勉強しなければなりません。",
    "Answer": "hit the books",
    "Answer_A": "hit the books",
    "Answer_B": "on cloud nine",
    "Answer_C": "spill the beans",
    "Answer_D": "break the ice",
    "JPN_Answer": "勉強をする",
    "JPN_Answer_A": "勉強をする",
    "JPN_Answer_B": "とても幸せである",
    "JPN_Answer_C": "秘密を漏らす",
    "JPN_Answer_D": "緊張をほぐす",
    "Phonetic_Symbols": "/hɪt ðə bʊks/",
    "Word_Synonyms": "study, prepare"
  },
  {
    "Idiom": "over the moon",
    "Explanation": "非常に喜んで",
    "Question": "She was _________ when she heard the good news.",
    "Question_JPN": "彼女は良い知らせを聞いてとても喜びました。",
    "Answer": "over the moon",
    "Answer_A": "over the moon",
    "Answer_B": "in hot water",
    "Answer_C": "under the weather",
    "Answer_D": "hit the books",
    "JPN_Answer": "非常に喜んで",
    "JPN_Answer_A": "非常に喜んで",
    "JPN_Answer_B": "困難に陥っている",
    "JPN_Answer_C": "体調が悪い",
    "JPN_Answer_D": "勉強をする",
    "Phonetic_Symbols": "/ˈəʊvər ðə muːn/",
    "Word_Synonyms": "very happy, ecstatic"
  },
  {
    "Idiom": "once in a blue moon",
    "Explanation": "めったに起こらない",
    "Question": "I see my cousins _________.",
    "Question_JPN": "私はいとこたちにめったに会いません。",
    "Answer": "once in a blue moon",
    "Answer_A": "once in a blue moon",
    "Answer_B": "under the weather",
    "Answer_C": "hit the books",
    "Answer_D": "spill the beans",
    "JPN_Answer": "めったに起こらない",
    "JPN_Answer_A": "めったに起こらない",
    "JPN_Answer_B": "体調が悪い",
    "JPN_Answer_C": "勉強をする",
    "JPN_Answer_D": "秘密を漏らす",
    "Phonetic_Symbols": "/wʌns ɪn ə bluː muːn/",
    "Word_Synonyms": "rarely, infrequently"
  },
  {
    "Idiom": "let the cat out of the bag",
    "Explanation": "秘密を明かす",
    "Question": "Don't _________ about the surprise party.",
    "Question_JPN": "サプライズパーティーについて秘密を明かさないでください。",
    "Answer": "let the cat out of the bag",
    "Answer_A": "let the cat out of the bag",
    "Answer_B": "hit the sack",
    "Answer_C": "on the ball",
    "Answer_D": "bite the bullet",
    "JPN_Answer": "秘密を明かす",
    "JPN_Answer_A": "秘密を明かす",
    "JPN_Answer_B": "寝る",
    "JPN_Answer_C": "よく気がつく",
    "JPN_Answer_D": "決心する",
    "Phonetic_Symbols": "/lɛt ðə kæt aʊt ɒv ðə bæɡ/",
    "Word_Synonyms": "reveal a secret, disclose"
  },
  {
    "Idiom": "cost an arm and a leg",
    "Explanation": "非常に高価である",
    "Question": "That car _________.",
    "Question_JPN": "その車は非常に高価です。",
    "Answer": "cost an arm and a leg",
    "Answer_A": "cost an arm and a leg",
    "Answer_B": "break the ice",
    "Answer_C": "spill the beans",
    "Answer_D": "hit the sack",
    "JPN_Answer": "非常に高価である",
    "JPN_Answer_A": "非常に高価である",
    "JPN_Answer_B": "緊張をほぐす",
    "JPN_Answer_C": "秘密を漏らす",
    "JPN_Answer_D": "寝る",
    "Phonetic_Symbols": "/kɒst ən ɑːrm ənd ə leɡ/",
    "Word_Synonyms": "very expensive, costly"
  },
  {
    "Idiom": "a piece of cake",
    "Explanation": "非常に簡単なこと",
    "Question": "The test was _________ for her because she studied well.",
    "Question_JPN": "彼女にとってその試験は非常に簡単でした。なぜならしっかり勉強したからです。",
    "Answer": "a piece of cake",
    "Answer_A": "a piece of cake",
    "Answer_B": "on thin ice",
    "Answer_C": "hit the sack",
    "Answer_D": "under the weather",
    "JPN_Answer": "非常に簡単なこと",
    "JPN_Answer_A": "非常に簡単なこと",
    "JPN_Answer_B": "危険な状況",
    "JPN_Answer_C": "寝る",
    "JPN_Answer_D": "体調が悪い",
    "Phonetic_Symbols": "/ə piːs əv keɪk/",
    "Word_Synonyms": "easy, simple"
  },
  {
    "Idiom": "burn the midnight oil",
    "Explanation": "夜遅くまで働く（または勉強する）",
    "Question": "She had to _________ to finish the project on time.",
    "Question_JPN": "彼女はプロジェクトを期限内に終わらせるために夜遅くまで働かなければなりませんでした。",
    "Answer": "burn the midnight oil",
    "Answer_A": "burn the midnight oil",
    "Answer_B": "cost an arm and a leg",
    "Answer_C": "spill the beans",
    "Answer_D": "break the ice",
    "JPN_Answer": "夜遅くまで働く",
    "JPN_Answer_A": "夜遅くまで働く",
    "JPN_Answer_B": "非常に高価である",
    "JPN_Answer_C": "秘密を漏らす",
    "JPN_Answer_D": "緊張をほぐす",
    "Phonetic_Symbols": "/bɜːrn ðə ˈmɪdnaɪt ɔɪl/",
    "Word_Synonyms": "work late, stay up late"
  },
  {
    "Idiom": "jump the gun",
    "Explanation": "フライングする、早まった行動をする",
    "Question": "Don’t _________ before we have all the details.",
    "Question_JPN": "すべての詳細を知る前にフライングしないでください。",
    "Answer": "jump the gun",
    "Answer_A": "jump the gun",
    "Answer_B": "burn the midnight oil",
    "Answer_C": "cost an arm and a leg",
    "Answer_D": "on cloud nine",
    "JPN_Answer": "フライングする",
    "JPN_Answer_A": "フライングする",
    "JPN_Answer_B": "夜遅くまで働く",
    "JPN_Answer_C": "非常に高価である",
    "JPN_Answer_D": "とても幸せである",
    "Phonetic_Symbols": "/dʒʌmp ðə ɡʌn/",
    "Word_Synonyms": "act prematurely, act too soon"
  },
  {
    "Idiom": "pull someone's leg",
    "Explanation": "冗談を言う、からかう",
    "Question": "Are you _________, or is this true?",
    "Question_JPN": "冗談を言っているの、それとも本当の話ですか？",
    "Answer": "pulling my leg",
    "Answer_A": "pulling my leg",
    "Answer_B": "jumping the gun",
    "Answer_C": "hitting the books",
    "Answer_D": "biting the bullet",
    "JPN_Answer": "冗談を言う",
    "JPN_Answer_A": "冗談を言う",
    "JPN_Answer_B": "フライングする",
    "JPN_Answer_C": "勉強をする",
    "JPN_Answer_D": "覚悟する",
    "Phonetic_Symbols": "/pʊl ˈsʌmwʌnz lɛɡ/",
    "Word_Synonyms": "tease, joke"
  },
  {
    "Idiom": "on the ball",
    "Explanation": "よく気がついている、仕事ができる",
    "Question": "You need to be _________ to catch these small details.",
    "Question_JPN": "これらの細かい点を見逃さないためには、注意を払う必要があります。",
    "Answer": "on the ball",
    "Answer_A": "on the ball",
    "Answer_B": "on thin ice",
    "Answer_C": "hit the books",
    "Answer_D": "spill the beans",
    "JPN_Answer": "よく気がついている",
    "JPN_Answer_A": "よく気がついている",
    "JPN_Answer_B": "危険な状況",
    "JPN_Answer_C": "勉強をする",
    "JPN_Answer_D": "秘密を漏らす",
    "Phonetic_Symbols": "/ɒn ðə bɔːl/",
    "Word_Synonyms": "alert, attentive"
  },
  {
    "Idiom": "hit the nail on the head",
    "Explanation": "的確なことを言う",
    "Question": "She _________ with her suggestion during the meeting.",
    "Question_JPN": "彼女は会議中に的確な提案をしました。",
    "Answer": "hit the nail on the head",
    "Answer_A": "hit the nail on the head",
    "Answer_B": "break the ice",
    "Answer_C": "spill the beans",
    "Answer_D": "on thin ice",
    "JPN_Answer": "的確なことを言う",
    "JPN_Answer_A": "的確なことを言う",
    "JPN_Answer_B": "緊張をほぐす",
    "JPN_Answer_C": "秘密を漏らす",
    "JPN_Answer_D": "危険な状況",
    "Phonetic_Symbols": "/hɪt ðə neɪl ɒn ðə hɛd/",
    "Word_Synonyms": "be correct, be accurate"
  },
  {
    "Idiom": "keep an eye on",
    "Explanation": "注意を払う、見守る",
    "Question": "Could you _________ my bag while I go to the restroom?",
    "Question_JPN": "トイレに行っている間、私のバッグを見ていてもらえますか？",
    "Answer": "keep an eye on",
    "Answer_A": "keep an eye on",
    "Answer_B": "on the ball",
    "Answer_C": "hit the sack",
    "Answer_D": "jump the gun",
    "JPN_Answer": "見守る",
    "JPN_Answer_A": "見守る",
    "JPN_Answer_B": "よく気がついている",
    "JPN_Answer_C": "寝る",
    "JPN_Answer_D": "フライングする",
    "Phonetic_Symbols": "/kiːp æn aɪ ɒn/",
    "Word_Synonyms": "watch, monitor"
  },
  {
    "Idiom": "go the extra mile",
    "Explanation": "一層の努力をする",
    "Question": "She always _________ to satisfy her clients.",
    "Question_JPN": "彼女はいつもお客様を満足させるために一層の努力をします。",
    "Answer": "goes the extra mile",
    "Answer_A": "goes the extra mile",
    "Answer_B": "pulls my leg",
    "Answer_C": "burns the midnight oil",
    "Answer_D": "hits the sack",
    "JPN_Answer": "一層の努力をする",
    "JPN_Answer_A": "一層の努力をする",
    "JPN_Answer_B": "冗談を言う",
    "JPN_Answer_C": "夜遅くまで働く",
    "JPN_Answer_D": "寝る",
    "Phonetic_Symbols": "/ɡəʊ ði ˈɛkstrə maɪl/",
    "Word_Synonyms": "make an extra effort, go above and beyond"
  }

  ];

  for (var wordData in wordsData) {
    try {
      // コレクション内のドキュメント数を取得し、新しい Word_id を設定
      final snapshot = await firestore.collection(collectionPath).get();
      final newWordId = snapshot.docs.length + 1;

      // データをFirebaseに保存
      await firestore.collection(collectionPath).add({
        'Word_id': newWordId,
        'Idion': wordData['Idiom'] ?? '', //イディオムの原型
        'Explanation': wordData['Explanation'] ?? '',  //イディオムの解説
        'Question': wordData['Question'] ?? '', //問題文（穴あき）
        'Question_JPN': wordData['Question_JPN'] ?? '',//問題文の日本語訳
        'Answer': wordData['Answer'], //答えのイディオム
        'Answer_A': wordData['Answer_A'],//選択肢のイディオム1
        'Answer_B': wordData['Answer_B'],//選択肢のイディオム2
        'Answer_C': wordData['Answer_C'],//選択肢のイディオム3
        'Answer_D': wordData['Answer_D'],//選択肢のイディオム4
        'JPN_Answer': wordData['JPN_Answer'],//答えのイディオムの日本語訳
        'JPN_Answer_A': wordData['JPN_Answer_A'],//選択肢1のイディオムの日本語訳
        'JPN_Answer_B': wordData['JPN_Answer_B'],//選択肢2のイディオムの日本語訳
        'JPN_Answer_C': wordData['JPN_Answer_C'],//選択肢3のイディオムの日本語訳
        'JPN_Answer_D': wordData['JPN_Answer_D'],//選択肢4のイディオムの日本語訳
        'Phonetic_Symbols': wordData['Phonetic_Symbols'] ?? '', //答えの発音記号
        'Word_Synonyms': wordData['Word_Synonyms'] ?? '',//答えの類義語
      });

      print('単語 "${wordData['word']}" を登録しました (Word_id: $newWordId)');
    } catch (e) {
      print('単語 "${wordData['word']}" の登録中にエラーが発生しました: $e');
    }
  }
}


