# Mega Store - Repositorio de Infraestructura

Este repositorio contiene la definición de infraestructura como código (Terraform) de la plataforma Mega Store. 

## Pipeline CI/CD
El archivo `.github/workflows/terraform.yml` define un flujo de despliegue continuo que se activa al hacer `push` a la rama `main`.
1. Inicializa Terraform.
2. Valida la sintaxis.
3. Aplica los cambios usando credenciales inyectadas de forma segura.

## Secretos Requeridos en GitHub Actions:
- `AWS_ACCESS_KEY_ID`: Credencial AWS
- `AWS_SECRET_ACCESS_KEY`: Credencial secreta AWS
- `GEMINI_API_KEY`: Clave de la API de Google Gemini
- `ADMIN_EMAIL`: Correo verificado en SES para envío de notificaciones

**Nota técnica:** Las funciones Lambda iniciales se crean a partir de un archivo `dummy.zip` con una regla de ciclo de vida (`ignore_changes`) para permitir que los repositorios de código de Lambda manejen sus propios despliegues mediante la AWS CLI.

Pipeline funcionando correctamente

Cuarto despliegue automático
