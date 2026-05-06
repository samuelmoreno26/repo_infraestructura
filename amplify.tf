resource "aws_amplify_app" "frontend" {
  name = "${var.project_name}-frontend"

  # Regla para Single Page Applications (React/Vite)
  # Redirige todo el tráfico a index.html para que React Router (si se usa) funcione correctamente.
  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    status = "200"
    target = "/index.html"
  }
  
  # Si el usuario configura un repositorio en el futuro, los comandos de compilación serían estos:
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT
}

# Creamos una rama principal
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "main"
}

output "amplify_app_id" {
  value = aws_amplify_app.frontend.id
}

output "amplify_default_domain" {
  value = "${aws_amplify_branch.main.branch_name}.${aws_amplify_app.frontend.default_domain}"
}
