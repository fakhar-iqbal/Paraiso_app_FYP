import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:paraiso/widgets/primary_button.dart';

import '../widgets/svgtextfield.dart';

class AddBankAccount extends StatefulWidget {
  AddBankAccount({super.key});

  @override
  State<AddBankAccount> createState() => _AddBankAccountState();
}

class _AddBankAccountState extends State<AddBankAccount> {
  List<String> countriesList = [
    "AT",
    "BE",
    "BG",
    "CH",
    "CY",
    "CZ",
    "DE",
    "DK",
    "EE",
    "ES",
    "FI",
    "FR",
    "GB",
    "GI",
    "GR",
    "HR",
    "HU",
    "IE",
    "IT",
    "LI",
    "LT",
    "LU",
    "LV",
    "MT",
    "NL",
    "NO",
    "PL",
    "PT",
    "RO",
    "SE",
    "SI",
    "SK",
    "US",
  ];

  List<String> accountTypes = [
    "Individual",
    "Company",
  ];

  String selectedCountry = "US";
  String selectedAccountType = "Individual";

  bool loading = false;

  TextEditingController _accountHolderName = TextEditingController();
  TextEditingController _accountNumber = TextEditingController();
  TextEditingController _routingNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            children: [
              SvgTextField(
                isPasswordField: false,
                label: "Account Holder Name",
                controller: _accountHolderName,
              ),
              const SizedBox(
                height: 15,
              ),
              SvgTextField(
                isPasswordField: false,
                label: "Account Number",
                controller: _accountNumber,
              ),
              const SizedBox(
                height: 15,
              ),
              SvgTextField(
                isPasswordField: false,
                label: "Routing Number",
                controller: _routingNumber,
              ),
              const SizedBox(
                height: 15,
              ),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue!;
                  });
                },
                items: countriesList.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(
                      country,
                      style: GoogleFonts.workSans(
                        color: Colors.green,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Select country',
                  hintStyle: GoogleFonts.workSans(
                    color: Colors.green,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              DropdownButtonFormField<String>(
                value: selectedAccountType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAccountType = newValue!;
                  });
                },
                items: accountTypes.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(
                      country,
                      style: GoogleFonts.workSans(
                        color: Colors.green,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Select Account Type',
                  hintStyle: GoogleFonts.workSans(
                    color: Colors.green,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.green,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryButton(onPressed: (){

              }, child: Text(loading ? "Loading..." : "Add Bank Account")),

            ],
          ),
        ),
      ),
    );
  }

  // addBankAccount(accountId) {
  //   firestore.collection('bankAccounts').add({
  //     'bankAccountHolder': _accountHolderName.text,
  //     'bankAccountNumber': _accountNumber.text,
  //     'routingNumber': _routingNumber.text,
  //     'country': selectedCountry.toLowerCase(),
  //     "currency": "usd",
  //     'providerId': currentUser!.uid,
  //     'type': selectedAccountType.toLowerCase(),
  //     'bank_stripe_id': accountId,
  //     'createdOn': DateTime.now(),
  //   });
  //
  //   loading = false;
  //
  //   _accountHolderName.clear();
  //   _accountNumber.clear();
  //   _routingNumber.clear();
  //   selectedCountry = "US";
  //
  //   Get.back();
  // }

  // void addSourceToCustomer() async {
  //   setState(() {
  //     loading = true;
  //   });
  //
  //   var userDoc =
  //       await firestore.collection('users').doc(currentUser!.uid).get();
  //
  //   var customerId = userDoc.data()!['customer_stripe_id'];
  //   // print("Customer ID: " + customerId.toString());
  //
  //   var url =
  //       Uri.parse('https://api.stripe.com/v1/customers/${customerId}/sources');
  //   var headers = {
  //     'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
  //     'Content-Type': 'application/x-www-form-urlencoded',
  //   };
  //   var body = _routingNumber.text == ""
  //       ? {
  //           'source[object]': 'bank_account',
  //           'source[country]': '${selectedCountry.toLowerCase()}',
  //           'source[currency]': 'usd',
  //           'source[account_holder_name]': '${_accountHolderName.text}',
  //           'source[account_holder_type]':
  //               '${selectedAccountType.toLowerCase()}',
  //           'source[account_number]': '${_accountNumber.text}',
  //         }
  //       : {
  //           'source[object]': 'bank_account',
  //           'source[country]': '${selectedCountry.toLowerCase()}',
  //           'source[currency]': 'usd',
  //           'source[account_holder_name]': '${_accountHolderName.text}',
  //           'source[account_holder_type]':
  //               '${selectedAccountType.toLowerCase()}',
  //           'source[account_number]': '${_accountNumber.text}',
  //           'source[routing_number]': '${_routingNumber.text}',
  //         };
  //
  //   var response = await http.post(
  //     url,
  //     headers: headers,
  //     body: body,
  //   );
  //
  //   if (response.statusCode == 200) {
  //     // Request was successful
  //     print('Source added to customer successfully');
  //     print(response.body);
  //
  //     addBankAccount(json.decode(response.body)['id']);
  //   } else {
  //     // Handle error
  //     print('Error: ${response.body}');
  //     return;
  //   }
  // }
}
