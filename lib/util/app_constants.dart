class AppConstants {
  static const Map<OrderStatus, String> orderStatuses = {
    OrderStatus.declined: 'Declined',
    OrderStatus.pending: 'Pending',
    OrderStatus.inProgress: 'In Progress',
    OrderStatus.fulfilled: 'Fulfilled',
  };

  static const Map<ProductType, String> productType = {
    ProductType.salade: 'Salade',
    ProductType.formule: 'Formule',
    ProductType.boissonfroide: 'Boisson froide',
    ProductType.boissonchaude: 'Boisson chaude',
    ProductType.accompagnement: 'Accompagnement',
    ProductType.entree: 'Entrée',
    ProductType.plat: 'Plat',
    ProductType.dessert: 'Dessert',
    ProductType.populaire: 'Populaire',
    ProductType.patisserie: 'Patisserie',
    ProductType.snack: 'Snack',
    ProductType.pain: 'Pain',
    ProductType.confiserie: 'Confiserie',
    ProductType.sandwich: 'Sandwich',
    ProductType.pizza: 'Pizza',
    ProductType.burger: 'Burger',
    ProductType.tacos: 'Tacos',
    ProductType.special: 'Spécial',
    ProductType.autres: 'Autres',
  };

  static const Map<GiftItems, String> giftItems = {
    GiftItems.burger: 'Burger',
    GiftItems.pizza: 'Pizza',
    GiftItems.coconut: 'Coconut',
    GiftItems.float: 'Float',
    GiftItems.buritto: 'Buritto',
    GiftItems.icecream: 'Icecream',
  };
}

enum OrderStatus {
  declined,
  pending,
  inProgress,
  fulfilled,
}

enum ProductType {
  salade,
  formule,
  boissonfroide,
  boissonchaude,
  accompagnement,
  entree,
  plat,
  dessert,
  populaire,
  patisserie,
  snack,
  pain,
  confiserie,
  sandwich,
  pizza,
  burger,
  tacos,
  special,
  autres,
}

enum GiftItems {
  burger,
  pizza,
  coconut,
  float,
  buritto,
  icecream
}
