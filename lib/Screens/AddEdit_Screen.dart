import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:my_shop/Providers/Product.dart';
import 'package:my_shop/Providers/Product_Provider.dart';
import 'package:provider/provider.dart';

class AddEditProductScreen extends StatefulWidget {
  static const routeName = '/AddEditProductScreen';
  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _priceFocousNode = FocusNode();
  final _descriptionFocousNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocousNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedProduct =
      Product(id: '', title: '', price: 0, description: '', imageUrl: '');

  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocousNode.addListener(_updateImageUrl);
    super.initState();
  }

  var _isInit = true;
  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId == null) return;
      final productinfo = Provider.of<ProductProvider>(context)
          .findProductById(productId.toString());
      _editedProduct = productinfo;
      if (productId != null) {
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl.toString();
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocousNode.removeListener(_updateImageUrl);
    _priceFocousNode.dispose();
    _descriptionFocousNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocousNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocousNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('jpg') &&
              !_imageUrlController.text.endsWith('png') &&
              !_imageUrlController.text.endsWith('jpeg'))) return;
    }
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isvaild = _form.currentState!.validate();
    if (!isvaild) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });

// this  is for eidit
    if (_editedProduct.id != "" && _editedProduct.id != null) {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error Ocurred!'),
                  content: Text('Something Went  Wrong.'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Close'))
                  ],
                ));
      }
    }
    // this is for addd
    else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error Ocurred!'),
                  content: Text('Something Went  Wrong.'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Close'))
                  ],
                ));
      }
      // finally {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }

    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Product'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveForm,
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black12,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                    key: _form,
                    child: ListView(
                      children: <Widget>[
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter Product Title'),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocousNode);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Title';
                            } else
                              return null;
                          },
                          onSaved: (value) {
                            _editedProduct = new Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: value.toString(),
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: _editedProduct.imageUrl);
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: InputDecoration(
                              labelText: 'Price',
                              hintText: 'Enter the Price of Product'),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          focusNode: _priceFocousNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocousNode);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Price';
                            } else if (double.tryParse(value) == null) {
                              return 'Please Enter Enter a Valid Number';
                            } else if (double.parse(value) <= 49) {
                              return 'Please Enter price above 49';
                            }
                          },
                          onSaved: (value) {
                            _editedProduct = new Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: double.parse(value.toString()),
                                imageUrl: _editedProduct.imageUrl,
                                isFavorite: _editedProduct.isFavorite);
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFocousNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Enter Description Details';
                            } else if (value.length < 10) {
                              return 'Description shoulf be atleast 10 Characters Long';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: value.toString(),
                                imageUrl: _editedProduct.imageUrl,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite);
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                                height: 120,
                                width: 100,
                                margin: EdgeInsets.only(
                                  top: 12,
                                  right: 10,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.black87)),
                                child: _imageUrlController.text.isEmpty
                                    ? Text('Enter Your Url')
                                    : FittedBox(
                                        child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ))),
                            Expanded(
                              child: TextFormField(
                                  // if we have Conrtoller  then not needed of initialValue
                                  //initialValue: _initValues['imageUrl'],
                                  decoration:
                                      InputDecoration(labelText: 'Image URL'),
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  controller: _imageUrlController,
                                  focusNode: _imageUrlFocousNode,
                                  onFieldSubmitted: (_) {
                                    _saveForm();
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please Entert the Image URL';
                                    } else if (!value.startsWith('http') &&
                                        !value.startsWith('https')) {
                                      return 'Please Enter a Valid Image Url';
                                    } else if (!value.endsWith('jpg') &&
                                        !value.endsWith('png') &&
                                        !value.endsWith('jpeg')) {
                                      return 'Please check the  Image is an vaild extension';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _editedProduct = new Product(
                                        id: _editedProduct.id,
                                        isFavorite: _editedProduct.isFavorite,
                                        title: _editedProduct.title,
                                        description: _editedProduct.description,
                                        price: _editedProduct.price,
                                        imageUrl: value.toString());
                                  }),
                            ),
                            //SizedBox(height: 200),
                          ],
                          // ElevatedButton(
                          //     onPressed: () {
                          //       // Validate returns true if the form is valid, or false otherwise.
                          //       // if (_form.currentState!.validate()) {
                          //       _saveForm();
                          //       //}
                          //     },
                          //     child: Text('Submit'),
                          //   ),
                        ),
                      ],
                    )),
              ));
  }
}
