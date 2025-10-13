"""
Custom dbt Operators for Airflow
Purpose: Extend Airflow with dbt-specific functionality
"""

from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults

class DbtRunOperator(BaseOperator):
    """
    Custom operator for running dbt models
    """
    
    @apply_defaults
    def __init__(
        self,
        dbt_project_path,
        dbt_command,
        profiles_dir=None,
        *args, **kwargs
    ):
        super(DbtRunOperator, self).__init__(*args, **kwargs)
        self.dbt_project_path = dbt_project_path
        self.dbt_command = dbt_command
        self.profiles_dir = profiles_dir

    def execute(self, context):
        import subprocess
        import os
        
        # Change to dbt project directory
        original_dir = os.getcwd()
        os.chdir(self.dbt_project_path)
        
        try:
            # Set profiles directory if specified
            env = os.environ.copy()
            if self.profiles_dir:
                env['DBT_PROFILES_DIR'] = self.profiles_dir
            
            # Execute dbt command
            self.log.info(f"Executing dbt command: {self.dbt_command}")
            result = subprocess.run(
                self.dbt_command,
                shell=True,
                env=env,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                raise Exception(f"dbt command failed: {result.stderr}")
                
            self.log.info("dbt command executed successfully")
            
        finally:
            os.chdir(original_dir)
