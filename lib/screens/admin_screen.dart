import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart';
import 'edit_product.dart';
import 'login_screen.dart';  // Thêm import cho trang Đăng nhập
import '../services/product_service.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'TRANG CHỦ ADMIN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Nút "Thoát" ở góc phải trên cùng
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutConfirmationDialog(context);  // Gọi hàm hiển thị hộp thoại xác nhận thoát
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: ProductList()), // Danh sách sản phẩm
          SizedBox(
            height: 30,
          ),
          // Nút "Thêm sản phẩm" ở dưới cùng
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen()),
                  );

                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added Product: ${result['name']}, ${result['type']}, ${result['price']}',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Text('Thêm sản phẩm',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Màu nền cho button
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị hộp thoại xác nhận thoát
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận thoát"),
          content: Text("Bạn có chắc chắn muốn thoát ra không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Đóng hộp thoại
              },
              child: Text('Hủy', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                // Điều hướng quay lại trang Đăng nhập
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Thoát', style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}

class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.only(left: 20.0, right: 20, top: 20),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.green,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Hiển thị hình ảnh với thiết lập tương tự file AddFood
                    data.containsKey('imageUrl') && data['imageUrl'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data['imageUrl'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tên sp: ${data['name']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold), // In đậm
                          ),
                          Text(
                            'Giá: ${data['price']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold), // In đậm
                          ),
                          Text(
                            'Loại sp: ${data['type']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold), // In đậm
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(
                                  docId: doc.id,
                                  currentName: data['name'],
                                  currentType: data['type'],
                                  currentPrice: data['price'],
                                  currentImageUrl: data['imageUrl'],
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, doc.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmationDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận"),
          content: Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                // Thực hiện xóa sản phẩm
                deleteProduct(docId);
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xóa
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product deleted successfully')),
                );
              },
              child: Text(
                'Xóa',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
