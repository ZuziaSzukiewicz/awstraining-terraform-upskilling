resource "aws_lb" "aws_upskilling_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg]
  subnets            = var.alb_subnets
}

resource "aws_lb_target_group" "awsupskilling_target_group" {
  name        = "${var.alb_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.aws_upskilling_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awsupskilling_target_group.arn
  }
}

resource "aws_ecs_task_definition" "awsupskilling_taskdef" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.image_uri
      secrets = var.secrets

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      
      environment = var.environment
    }
  ])

}

resource "aws_ecs_service" "awsupskilling_service" {
  name            = var.service_name
  cluster = var.cluster_id
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.awsupskilling_taskdef.arn

  depends_on = [aws_lb_listener.http]

  network_configuration {
    subnets          = var.task_subnets
    security_groups  = var.task_sg_ids
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.awsupskilling_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

}