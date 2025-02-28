#!/bin/bash

# Check if a project name is provided, if not, default to "my-project"
if [ -z "$1" ]; then
    echo "No project name provided. Defaulting to 'my-project'."
    PROJECT_DIR="my-project"
else
    PROJECT_DIR=$1
    echo "Creating project with name: $PROJECT_DIR"
fi

# Create the project root folder
mkdir -p $PROJECT_DIR

# Create the subdirectories for dags, logs, plugins, and data
mkdir -p $PROJECT_DIR/dags
mkdir -p $PROJECT_DIR/logs/scheduler
mkdir -p $PROJECT_DIR/logs/webserver
mkdir -p $PROJECT_DIR/logs/task_logs
mkdir -p $PROJECT_DIR/plugins
mkdir -p $PROJECT_DIR/data/raw_data
mkdir -p $PROJECT_DIR/data/processed_data

# Create initial placeholder files
touch $PROJECT_DIR/dags/my_dag.py
touch $PROJECT_DIR/dags/another_dag.py
touch $PROJECT_DIR/plugins/my_plugin.py
touch $PROJECT_DIR/requirements.txt
touch $PROJECT_DIR/Dockerfile
touch $PROJECT_DIR/airflow.cfg
touch $PROJECT_DIR/spark_processing.py

# Create docker-compose.yml file
cat <<EOL > $PROJECT_DIR/docker-compose.yml
version: '3.7'

services:
  # Airflow PostgreSQL Database
  postgres:
    image: postgres:16.0
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
      - POSTGRES_DB=\${POSTGRES_DB}

  # Airflow Webserver
  airflow_webserver:
    image: apache/airflow:latest
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
      - ./data:/opt/airflow/data
    environment:
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@airflow_db:5432/\${POSTGRES_DB}

  # Kafka Broker
  kafka_broker:
    image: confluentinc/cp-kafka:latest
    environment:
      - KAFKA_ZOOKEEPER_CONNECT=kafka_zookeeper:2181

  # Zookeeper
  kafka_zookeeper:
    image: confluentinc/cp-zookeeper:latest

  # Spark Master Node
  spark_master:
    image: bitnami/spark:3
    volumes:
      - ./data:/opt/bitnami/spark/data
    ports:
      - 8085:8080
    environment:
      - SPARK_UI_PORT=8085

volumes:
  postgres_data: # Persistent volume for PostgreSQL data
EOL

# Output project structure and message
echo "Project structure for '$PROJECT_DIR' has been created."
tree $PROJECT_DIR
