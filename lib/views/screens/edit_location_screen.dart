// views/screens/edit_location_screen.dart
import 'package:flutter/material.dart';
import '../../controllers/location_controller.dart';
import '../../models/location.dart';

class EditLocationScreen extends StatefulWidget {
  final Location location;
  
  const EditLocationScreen({super.key, required this.location});
  
  @override
  _EditLocationScreenState createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationController _locationController = LocationController();
  
  late String _name;
  late String _description;
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Inicializar con los valores de la ubicación
    _name = widget.location.name;
    _description = widget.location.description;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ubicación'),
        backgroundColor: Colors.green,
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
                        prefixIcon: const Icon(Icons.place),
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
                      onPressed: _updateLocation,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
  
  Future<void> _updateLocation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final updatedLocation = Location(
          id: widget.location.id,
          name: _name,
          description: _description,
        );
        
        // Actualizar la ubicación
        await _locationController.updateLocation(updatedLocation);
        
        Navigator.pop(context, true); // Volver a la pantalla anterior con resultado positivo
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}