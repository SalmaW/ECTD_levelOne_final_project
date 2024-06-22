import '../pages/client/clients.dart';
import '../pages/product/products.dart';
import '../pages/all_sales_page.dart';
// import '../pages/all_sales.dart';
import '../pages/sale_op.dart';
import '../pages/category/categories.dart';
import '../helpers/sql_helper.dart';
import '../widgets/grid_view_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  bool isTableInitialized = false;
  bool isDBRestored = false;

  @override
  void initState() {
    super.initState();
    // Defer the initialization to the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeTables();
    });
  }

  void initializeTables() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      isDBRestored = await sqlHelper.restoreDatabaseIfNeeded(context);
      if (!isDBRestored) {
        isTableInitialized = true;
        isLoading = false;
      } else {
        isTableInitialized = isDBRestored;
        isLoading = false;
      }
      setState(() {});
    } catch (e) {
      print('Error initializing tables: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(),
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height / 3 +
                      (kIsWeb ? 0 : 15), // 24 works on my emulator
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Easy Pos',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: isLoading
                                  ? Transform.scale(
                                      scale: .5,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: isTableInitialized
                                          ? Colors.green
                                          : Colors.red,
                                      radius: 10,
                                    ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        headerItem('Exchange rate', '1USD = 50 EGP'),
                        headerItem('Today\'s sales', '1000 EGP'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: const Color(0xffFAFAFA),
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  GridViewItem(
                    color: Colors.orange,
                    iconData: Icons.receipt,
                    label: 'All Sales',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const AllSales()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.pink[200],
                    iconData: Icons.inventory_2,
                    label: 'Products',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const ProductsScreen()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.lightBlue,
                    iconData: Icons.people,
                    label: 'Clients',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const ClientsScreen()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.green,
                    iconData: Icons.shopping_basket,
                    label: 'New Sale',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (ctx) => const SaleOp()));
                    },
                  ),
                  GridViewItem(
                    color: Colors.yellow,
                    iconData: Icons.category,
                    label: 'Categories',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const CategoriesScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget headerItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: const Color(0xff206ce1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  // fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white54,
                  // fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
