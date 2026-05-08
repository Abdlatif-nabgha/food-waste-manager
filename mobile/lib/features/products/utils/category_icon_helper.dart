class CategoryIconHelper {
  static String getIcon(String categoryName) {
    switch (categoryName.toLowerCase().trim()) {
      case 'fruits':
        return '🍎';
      case 'vegetables':
        return '🥦';
      case 'dairy':
        return '🥛';
      case 'meat':
        return '🍖';
      case 'fish & seafood':
      case 'fish':
      case 'seafood':
        return '🐟';
      case 'bakery':
        return '🍞';
      case 'drinks':
        return '🥤';
      case 'frozen foods':
        return '❄️';
      case 'snacks':
        return '🍿';
      case 'canned foods':
        return '🥫';
      case 'spices':
        return '🧂';
      case 'ready meals':
        return '🍱';
      default:
        return '🏷️';
    }
  }

  static String formatNameWithIcon(String categoryName) {
    return '${getIcon(categoryName)} $categoryName';
  }
}
