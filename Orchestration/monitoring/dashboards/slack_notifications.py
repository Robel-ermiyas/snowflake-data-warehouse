"""
Slack Notifications for Data Pipeline Alerts
Purpose: Send real-time alerts to Slack for pipeline failures and data quality issues
Dependencies: Slack webhook URL, airflow connections
"""

import json
import requests
from airflow.models import Variable
from airflow.hooks.base_hook import BaseHook

class SlackNotifier:
    """
    Handles Slack notifications for pipeline monitoring
    """
    
    def __init__(self, webhook_url=None):
        self.webhook_url = webhook_url or Variable.get("slack_webhook_url", default_var=None)
    
    def send_pipeline_alert(self, dag_id, task_id, execution_date, error_message, severity="error"):
        """
        Send pipeline failure alert to Slack
        """
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": f"🚨 Pipeline {severity.upper()}: {dag_id}"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Task:* {task_id}"
                        },
                        {
                            "type": "mrkdwn", 
                            "text": f"*Execution:* {execution_date}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Severity:* {severity}"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Error Details:*\n```{error_message}```"
                    }
                },
                {
                    "type": "actions",
                    "elements": [
                        {
                            "type": "button",
                            "text": {
                                "type": "plain_text",
                                "text": "View in Airflow"
                            },
                            "url": f"http://airflow.example.com/task?dag_id={dag_id}&task_id={task_id}&execution_date={execution_date}"
                        }
                    ]
                }
            ]
        }
        
        self._send_slack_message(message)
    
    def send_data_quality_alert(self, check_name, failed_count, threshold, actual_value):
        """
        Send data quality violation alert to Slack
        """
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text", 
                        "text": "📊 Data Quality Alert"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Check:* {check_name}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Failed Records:* {failed_count}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Threshold:* {threshold}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Actual:* {actual_value}"
                        }
                    ]
                }
            ]
        }
        
        self._send_slack_message(message)
    
    def send_daily_summary(self, success_count, failed_count, total_duration, data_freshness):
        """
        Send daily pipeline summary to Slack
        """
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": "📈 Daily Pipeline Summary"
                    }
                },
                {
                    "type": "section", 
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Successful Runs:* {success_count}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Failed Runs:* {failed_count}"
                        },
                        {
                            "type": "mrkdwn", 
                            "text": f"*Total Duration:* {total_duration}min"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Data Freshness:* {data_freshness}h"
                        }
                    ]
                }
            ]
        }
        
        self._send_slack_message(message)
    
    def _send_slack_message(self, message):
        """
        Internal method to send message to Slack
        """
        if not self.webhook_url:
            print("Slack webhook URL not configured")
            return
        
        try:
            response = requests.post(
                self.webhook_url,
                data=json.dumps(message),
                headers={'Content-Type': 'application/json'}
            )
            response.raise_for_status()
        except Exception as e:
            print(f"Failed to send Slack message: {e}")
