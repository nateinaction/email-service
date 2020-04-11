# Handle incoming email
## SNS first because it contains email body: https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-action-lambda-event.html
## lambda to process mail: needs recipient/fowarding mapping: https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/
## iam policy for lambda to send mail https://www.terraform.io/docs/providers/aws/r/ses_identity_policy.html
## ses recipient rule https://www.terraform.io/docs/providers/aws/r/ses_receipt_rule.html

### Thoughts on lambda env vars:
//    "spamVerdict": {
//      "status": "PASS"
//    },
//    "virusVerdict": {
//      "status": "PASS"
//    },
//    "spfVerdict": {
//      "status": "PASS"
//    },
//    "dkimVerdict": {
//      "status": "GRAY"
//    },
//    "dmarcVerdict": {
//      "status": "GRAY"
//    },


