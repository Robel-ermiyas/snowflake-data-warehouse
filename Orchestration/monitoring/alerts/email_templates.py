"""
Email Templates for Data Pipeline Alerts
Purpose: HTML email templates for pipeline failures and data quality issues
Dependencies: Airflow email configuration
"""

class EmailTemplates:
    """
    HTML email templates for monitoring alerts
    """
    
    @staticmethod
    def pipeline_failure_template(dag_id, task_id, execution_date, error_message, log_url):
        """
        Template for pipeline failure alerts
        """
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background-color: #ff4444; color: white; padding: 10px; border-radius: 5px; }}
                .content {{ margin: 20px 0; }}
                .detail {{ background-color: #f8f9fa; padding: 10px; border-radius: 5px; }}
                .button {{ background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h2>🚨 Data Pipeline Failure</h2>
            </div>
            
            <div class="content">
                <p><strong>Pipeline:</strong> {dag_id}</p>
                <p><strong>Failed Task:</strong> {task_id}</p>
                <p><strong>Execution Date:</strong> {execution_date}</p>
                
                <div class="detail">
                    <p><strong>Error Details:</strong></p>
                    <pre>{error_message}</pre>
                </div>
                
                <p>
                    <a href="{log_url}" class="button">View Logs</a>
                </p>
            </div>
            
            <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd;">
                <p><small>This is an automated alert from the Data Pipeline Monitoring System.</small></p>
            </div>
        </body>
        </html>
        """
    
    @staticmethod
    def data_quality_alert_template(check_name, failed_count, threshold, table_name, check_sql):
        """
        Template for data quality violation alerts
        """
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background-color: #ffa500; color: white; padding: 10px; border-radius: 5px; }}
                .content {{ margin: 20px 0; }}
                .metric {{ display: inline-block; margin: 10px; padding: 10px; background-color: #f8f9fa; border-radius: 5px; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h2>📊 Data Quality Alert</h2>
            </div>
            
            <div class="content">
                <p><strong>Quality Check Failed:</strong> {check_name}</p>
                
                <div class="metric">
                    <strong>Failed Records:</strong> {failed_count}
                </div>
                <div class="metric">
                    <strong>Threshold:</strong> {threshold}
                </div>
                <div class="metric">
                    <strong>Table:</strong> {table_name}
                </div>
                
                <div style="margin-top: 20px;">
                    <p><strong>Check SQL:</strong></p>
                    <pre style="background-color: #f8f9fa; padding: 10px; border-radius: 5px;">{check_sql}</pre>
                </div>
            </div>
            
            <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd;">
                <p><small>This is an automated alert from the Data Quality Monitoring System.</small></p>
            </div>
        </body>
        </html>
        """
    
    @staticmethod
    def daily_summary_template(success_count, failed_count, total_duration, data_freshness, top_issues):
        """
        Template for daily pipeline summary
        """
        issues_html = "".join([f"<li>{issue}</li>" for issue in top_issues])
        
        return f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background-color: #28a745; color: white; padding: 10px; border-radius: 5px; }}
                .metrics {{ display: flex; justify-content: space-between; margin: 20px 0; }}
                .metric-card {{ background-color: #f8f9fa; padding: 15px; border-radius: 5px; text-align: center; flex: 1; margin: 0 10px; }}
                .metric-value {{ font-size: 24px; font-weight: bold; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h2>📈 Daily Pipeline Summary</h2>
            </div>
            
            <div class="metrics">
                <div class="metric-card">
                    <div class="metric-value" style="color: #28a745;">{success_count}</div>
                    <div>Successful Runs</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value" style="color: #ff4444;">{failed_count}</div>
                    <div>Failed Runs</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value" style="color: #007bff;">{total_duration}m</div>
                    <div>Total Duration</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value" style="color: #6c757d;">{data_freshness}h</div>
                    <div>Data Freshness</div>
                </div>
            </div>
            
            <div style="margin-top: 20px;">
                <h3>Top Issues Today</h3>
                <ul>
                    {issues_html}
                </ul>
            </div>
            
            <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd;">
                <p><small>This is an automated daily summary from the Data Pipeline Monitoring System.</small></p>
            </div>
        </body>
        </html>
        """
