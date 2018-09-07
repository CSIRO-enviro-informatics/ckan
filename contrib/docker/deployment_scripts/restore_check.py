import requests
import argparse
import unittest
import xmlrunner
import io
import sys
import datetime
requests.packages.urllib3.disable_warnings()


class DarRestoreTest(unittest.TestCase):
    def test_dataset_size_gap(self):
        self.assertLessEqual(abs(self.check_dataset_size_gap(self.prod_url, self.deploy_url)), self.max_gap_size)

    def test_dataset_date_gap(self):

        self.assertLessEqual(abs(self.check_date_gap_to_prod(self.prod_url, self.deploy_url)), datetime.timedelta(days=self.max_gap_days))

    def check_dataset_size_gap(self, prod_url, deploy_url):
        path = 'api/3/action/package_list'
        prod_dataset_size = len(requests.get(prod_url+path, verify=False).json().get('result'))
        deploy_dataset_size = len(requests.get(deploy_url+path, verify=False).json().get('result'))
        return prod_dataset_size - deploy_dataset_size

    def check_date_gap_to_prod(self, prod_url, deploy_url):
        path = 'api/3/action/recently_changed_packages_activity_list?limit=1'
        prod_latest_dataset = requests.get(prod_url+path, verify=False).json().get('result')[0].get('data').get('package').get('metadata_modified')
        deploy_latest_dataset = requests.get(deploy_url+path, verify=False).json().get('result')
        if(len(deploy_latest_dataset) > 0):
            deploy_latest_dataset_date = deploy_latest_dataset[0].get('data').get('package').get('metadata_modified')
            return self.str_datetime(prod_latest_dataset) - self.str_datetime(deploy_latest_dataset_date)
        else:
            # deploy doesn't have dataset yet
            return datetime.timedelta(seconds=sys.maxsize)
    
    def str_datetime(self, date_str):
        return datetime.datetime.strptime(date_str, '%Y-%m-%dT%H:%M:%S.%f')

# Example:
#    python restore_check.py -h   
#    python restore_check.py
#    python restore_check.py --prod_url 'https://hub.research.csiro.au/' --deploy_url 'https://hub-staging.research.csiro.au/' --max_gap_days 360 --max_gap_size 200
if __name__ == '__main__':
    parser = argparse.ArgumentParser("Ckan Restore Result Check")
    parser.add_argument("--prod_url", help='Base ckan site url for result check')
    parser.add_argument("--deploy_url", help='Target ckan site url to be checked')
    parser.add_argument("--max_gap_days", help='Max diff days allowed. Test exception will be trigged when exceed this days')
    parser.add_argument("--max_gap_size", help='Max diff dataset size allowed. Test exception will be trigged when exceed this size')
    argv = parser.parse_args()
    # Set default values
    DarRestoreTest.prod_url = 'https://hub.research.csiro.au/'
    DarRestoreTest.deploy_url = 'https://hub-dev.research.csiro.au/'
    DarRestoreTest.max_gap_days = 2
    DarRestoreTest.max_gap_size = 2

    if argv.prod_url != None:
        DarRestoreTest.prod_url = argv.prod_url
    if argv.deploy_url != None:
        DarRestoreTest.deploy_url = argv.deploy_url
    if argv.max_gap_days != None:
        DarRestoreTest.max_gap_days = int(argv.max_gap_days)
    if argv.max_gap_size != None:
        DarRestoreTest.max_gap_size = int(argv.max_gap_size)

    # must set argv param, or else unittest will read sys.argv and cause exception
    unittest.main(
        testRunner=xmlrunner.XMLTestRunner(output='test-reports'),
        failfast=False, 
        buffer=False, 
        catchbreak=False, 
        argv=['DarRestoreTest']
        )
    # print('Dataset size gap between prod and deploy (prod - deploy):\t ', check_dataset_size_gap(prod_url, deploy_url))
    # print('Recent update gap between prod and deploy (prod - deploy):\t ', check_date_gap_to_prod(prod_url, deploy_url))

