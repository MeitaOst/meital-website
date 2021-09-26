
variable "lambdaArn"{

}

variable "lambdaArnMail"{

}

variable "lambdaArnSms"{

}

resource "aws_iam_role" "step_function_role" {
  name               = "step_function_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "step_function_policy" {
  name    = "step_function_policy"
  role    = aws_iam_role.step_function_role.id

  policy  = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "${var.lambdaArn}"
      }
    ]
  }
  EOF
}


resource "aws_sfn_state_machine" "state_machine" {
  name     = "state-machine"
  role_arn = aws_iam_role.step_function_role.arn

   definition = <<EOF

{
  "Comment": "An example of the Amazon States Language using a choice state.",
  "StartAt": "SendReminder",
  "States": {
    "SendReminder": {
      "Type": "Wait",
      "SecondsPath": "$.waitSeconds",
      "Next": "ChoiceState"
    },
    "ChoiceState": {
      "Type" : "Choice",
      "Choices": [
        {
          "Variable": "$.preference",
          "StringEquals": "email",
          "Next": "EmailReminder"
        },
        {
          "Variable": "$.preference",
          "StringEquals": "sms",
          "Next": "TextReminder"
        },
        {
          "Variable": "$.preference",
          "StringEquals": "both",
          "Next": "BothReminders"
        }
      ],
      "Default": "DefaultState"
    },

    "EmailReminder": {
      "Type" : "Task",
      "Resource": "${var.lambdaArnMail}",
      "Next": "NextState"
    },

    "TextReminder": {
      "Type" : "Task",
      "Resource": "${var.lambdaArnSms}",
      "Next": "NextState"
    },
    
    "BothReminders": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "EmailReminderPar",
          "States": {
            "EmailReminderPar": {
              "Type" : "Task",
              "Resource": "${var.lambdaArnMail}",
              "End": true
            }
          }
        },
        {
          "StartAt": "TextReminderPar",
          "States": {
            "TextReminderPar": {
              "Type" : "Task",
              "Resource": "${var.lambdaArnSms}",
              "End": true
            }
          }
        }
      ],
      "Next": "NextState"
    },
    
    "DefaultState": {
      "Type": "Fail",
      "Error": "DefaultStateError",
      "Cause": "No Matches!"
    },

    "NextState": {
      "Type": "Pass",
      "End": true
    }
  }
}


EOF
}
