class Config {
  // static const String apiUrl = 'http://192.168.30.18:3050/';
  // static const String apiUrl = 'http://localhost:3050/';
  static const String apiUrl = 'http://192.168.30.18:3050/';
  // static const String apiUrl = 'https://salesinventory.5lsolutions.com/';
  // static const String apiUrl = 'https://sois.5lsolutions.com/';

  static const String authenticationLoginAPI = 'login/poslogin';
  static const String salesDetailAPI = 'salesdetails/save';
  static const String getcategoryAPI = 'productprice/getcategory';
  static const String getpriceAPI = 'productprice/getprice';
  static const String getdetailidAPI = 'salesdetails/getdetailid';
  static const String getdetailsAPI = 'salesdetails/getdetails';
  static const String getCategoryAPI = 'category/active';
  static const String getBranchAPI = 'branch/getbranch';
  static const String getPosConfig = 'pos/getposconfig';
  static const String startShiftAPI = 'posshiftlog/startshift';
  static const String getPOSShiftAPI = 'posshiftlog/getposshift';
  static const String endShiftAPI = 'posshiftlog/endshift';
  static const String discountRateAPI = 'discount/getactive';
  static const String getDiscountAPI = 'discount/load';
  static const String getPaymentAPI = 'payment/getactive';
  static const String getPromoAPI = 'promo/getactive';
  static const String salesDiscountAPI = 'promo/salesdiscount';
}
