enum WardrobeCategory {
  tops('tops', '상의'),
  bottoms('bottoms', '하의'),
  outerwear('outerwear', '아우터'),
  dresses('dresses', '원피스'),
  shoes('shoes', '신발'),
  bags('bags', '가방'),
  accessories('accessories', '액세서리');

  const WardrobeCategory(this.key, this.label);
  final String key;
  final String label;
}

const subcategoryMap = <WardrobeCategory, List<String>>{
  WardrobeCategory.tops: ['티셔츠', '셔츠', '블라우스', '니트', '맨투맨', '후드', '민소매'],
  WardrobeCategory.bottoms: ['청바지', '슬랙스', '면바지', '반바지', '스커트', '레깅스'],
  WardrobeCategory.outerwear: ['자켓', '코트', '패딩', '가디건', '바람막이', '점퍼'],
  WardrobeCategory.dresses: ['미니', '미디', '맥시', '셔츠원피스', '니트원피스'],
  WardrobeCategory.shoes: ['스니커즈', '구두', '부츠', '샌들', '슬리퍼', '로퍼'],
  WardrobeCategory.bags: ['백팩', '토트백', '크로스백', '클러치', '숄더백'],
  WardrobeCategory.accessories: ['모자', '벨트', '스카프', '주얼리', '시계', '선글라스'],
};

enum WardrobeFit {
  oversized('oversized', '오버사이즈'),
  regular('regular', '레귤러'),
  slim('slim', '슬림');

  const WardrobeFit(this.key, this.label);
  final String key;
  final String label;
}

enum WardrobePattern {
  solid('solid', '무지'),
  stripe('stripe', '스트라이프'),
  check('check', '체크'),
  floral('floral', '플로럴'),
  dot('dot', '도트'),
  print_('print', '프린트'),
  other('other', '기타');

  const WardrobePattern(this.key, this.label);
  final String key;
  final String label;
}

enum WardrobeSeason {
  spring('spring', '봄'),
  summer('summer', '여름'),
  fall('fall', '가을'),
  winter('winter', '겨울');

  const WardrobeSeason(this.key, this.label);
  final String key;
  final String label;
}
