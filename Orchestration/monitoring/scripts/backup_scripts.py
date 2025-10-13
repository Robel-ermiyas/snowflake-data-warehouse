"""
Data Pipeline Backup Scripts
Purpose: Backup critical pipeline components and configurations
Usage: Scheduled backups for disaster recovery
"""

import os
import shutil
import json
import snowflake.connector
from datetime import datetime
import boto3
from botocore.exceptions import ClientError

class PipelineBackupManager:
    """
    Manages backups for data pipeline components
    """
    
    def __init__(self, snowflake_config, s3_config=None, local_backup_path="/backups"):
        self.snowflake_config = snowflake_config
        self.s3_config = s3_config
        self.local_backup_path = local_backup_path
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Create backup directory
        os.makedirs(self.local_backup_path, exist_ok=True)
    
    def backup_database_schemas(self):
        """
        Backup database schema definitions
        """
        try:
            conn = snowflake.connector.connect(**self.snowflake_config)
            cursor = conn.cursor()
            
            # Get all schemas
            cursor.execute("SHOW SCHEMAS IN DATABASE")
            schemas = [row[1] for row in cursor.fetchall() if row[1] in ['BRONZE', 'SILVER', 'GOLD']]
            
            schema_backups = {}
            
            for schema in schemas:
                # Get tables in schema
                cursor.execute(f"SHOW TABLES IN {schema}")
                tables = [row[1] for row in cursor.fetchall()]
                
                schema_definitions = {}
                for table in tables:
                    # Get table DDL
                    cursor.execute(f"SELECT GET_DDL('TABLE', '{schema}.{table}')")
                    ddl = cursor.fetchone()[0]
                    schema_definitions[table] = ddl
                
                schema_backups[schema] = schema_definitions
            
            cursor.close()
            conn.close()
            
            # Save to file
            backup_file = f"{self.local_backup_path}/schema_backup_{self.timestamp}.json"
            with open(backup_file, 'w') as f:
                json.dump(schema_backups, f, indent=2)
            
            return backup_file
            
        except Exception as e:
            print(f"Schema backup failed: {e}")
            return None
    
    def backup_stored_procedures(self):
        """
        Backup Snowflake stored procedures
        """
        try:
            conn = snowflake.connector.connect(**self.snowflake_config)
            cursor = conn.cursor()
            
            # Get stored procedures
            cursor.execute("SHOW USER PROCEDURES")
            procedures = cursor.fetchall()
            
            procedure_backups = {}
            
            for proc in procedures:
                proc_name = proc[1]
                proc_schema = proc[2]
                
                # Get procedure DDL
                cursor.execute(f"SELECT GET_DDL('PROCEDURE', '{proc_schema}.{proc_name}')")
                ddl = cursor.fetchone()[0]
                procedure_backups[f"{proc_schema}.{proc_name}"] = ddl
            
            cursor.close()
            conn.close()
            
            # Save to file
            backup_file = f"{self.local_backup_path}/procedures_backup_{self.timestamp}.json"
            with open(backup_file, 'w') as f:
                json.dump(procedure_backups, f, indent=2)
            
            return backup_file
            
        except Exception as e:
            print(f"Stored procedure backup failed: {e}")
            return None
    
    def backup_airflow_dags(self, dags_path):
        """
        Backup Airflow DAG files
        """
        try:
            # Create backup of DAGs directory
            backup_dir = f"{self.local_backup_path}/airflow_dags_{self.timestamp}"
            shutil.copytree(dags_path, backup_dir)
            
            return backup_dir
            
        except Exception as e:
            print(f"Airflow DAGs backup failed: {e}")
            return None
    
    def backup_dbt_projects(self, dbt_projects):
        """
        Backup dbt project files
        """
        try:
            dbt_backups = {}
            
            for project_name, project_path in dbt_projects.items():
                if os.path.exists(project_path):
                    backup_dir = f"{self.local_backup_path}/dbt_{project_name}_{self.timestamp}"
                    shutil.copytree(project_path, backup_dir)
                    dbt_backups[project_name] = backup_dir
            
            return dbt_backups
            
        except Exception as e:
            print(f"dbt projects backup failed: {e}")
            return None
    
    def upload_to_s3(self, local_path, s3_bucket, s3_prefix):
        """
        Upload backup files to S3
        """
        if not self.s3_config:
            print("S3 configuration not provided")
            return False
        
        try:
            s3_client = boto3.client('s3', **self.s3_config)
            
            if os.path.isfile(local_path):
                # Upload single file
                s3_key = f"{s3_prefix}/{os.path.basename(local_path)}"
                s3_client.upload_file(local_path, s3_bucket, s3_key)
                return True
            elif os.path.isdir(local_path):
                # Upload directory
                for root, dirs, files in os.walk(local_path):
                    for file in files:
                        local_file_path = os.path.join(root, file)
                        s3_key = f"{s3_prefix}/{os.path.basename(local_path)}/{os.path.relpath(local_file_path, local_path)}"
                        s3_client.upload_file(local_file_path, s3_bucket, s3_key)
                return True
                
        except ClientError as e:
            print(f"S3 upload failed: {e}")
            return False
    
    def run_complete_backup(self, dags_path, dbt_projects, upload_to_s3=False):
        """
        Run complete backup of all pipeline components
        """
        backup_report = {
            "timestamp": self.timestamp,
            "backups": {}
        }
        
        print("Starting comprehensive pipeline backup...")
        
        # Backup database schemas
        print("Backing up database schemas...")
        schema_backup = self.backup_database_schemas()
        if schema_backup:
            backup_report["backups"]["schemas"] = schema_backup
        
        # Backup stored procedures
        print("Backing up stored procedures...")
        procedure_backup = self.backup_stored_procedures()
        if procedure_backup:
            backup_report["backups"]["procedures"] = procedure_backup
        
        # Backup Airflow DAGs
        print("Backing up Airflow DAGs...")
        dags_backup = self.backup_airflow_dags(dags_path)
        if dags_backup:
            backup_report["backups"]["airflow_dags"] = dags_backup
        
        # Backup dbt projects
        print("Backing up dbt projects...")
        dbt_backup = self.backup_dbt_projects(dbt_projects)
        if dbt_backup:
            backup_report["backups"]["dbt_projects"] = dbt_backup
        
        # Upload to S3 if requested
        if upload_to_s3 and self.s3_config:
            print("Uploading backups to S3...")
            for backup_type, backup_path in backup_report["backups"].items():
                if backup_path:
                    success = self.upload_to_s3(
                        backup_path, 
                        "pipeline-backups",
                        f"backups/{self.timestamp}/{backup_type}"
                    )
                    backup_report["backups"][f"{backup_type}_s3_upload"] = success
        
        # Save backup report
        report_file = f"{self.local_backup_path}/backup_report_{self.timestamp}.json"
        with open(report_file, 'w') as f:
            json.dump(backup_report, f, indent=2)
        
        print(f"Backup completed. Report saved to: {report_file}")
        return backup_report
