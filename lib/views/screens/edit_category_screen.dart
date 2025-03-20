// views/screens/edit_category_screen.dart
import 'package:flutter/material.dart';
import '../../controllers/category_controller.dart';
import '../../models/category.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;
  
  const EditCategoryScreen({super.key, required this.category});
  
  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoryController _categoryController = CategoryController();
  
  late String _name;
  late String _description;
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Inicializar con los valores de la categoría
    _name = widget.category.name;
    _description = widget.category.description;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Categoría'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.category),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un nombre';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null) {
                          _name = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    TextFormField(
                      initialValue: _description,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value ?? '';
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón de guardar
                    ElevatedButton.icon(
                      onPressed: _updateCategory,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final updatedCategory = Category(
          id: widget.category.id,
          name: _name,
          description: _description,
        );
        
        // Actualizar la categoría
        await _categoryController.updateCategory(updatedCategory);

        Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la categoría: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}