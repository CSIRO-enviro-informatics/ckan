import requests
from datetime import datetime
requests.packages.urllib3.disable_warnings()


def check_dataset_size_gap(prod_url, deploy_url):
    path = 'api/3/action/package_list'
    prod_dataset_size = len(requests.get(prod_url+path, verify=False).json().get('result'))
    deploy_dataset_size = len(requests.get(deploy_url+path, verify=False).json().get('result'))

    return prod_dataset_size - deploy_dataset_size

def check_date_gap_to_prod(prod_url, deploy_url):
    path = 'api/3/action/recently_changed_packages_activity_list?limit=1'
    prod_latest_dataset = requests.get(prod_url+path, verify=False).json().get('result')[0].get('data').get('package').get('metadata_modified')
    deploy_latest_dataset = requests.get(deploy_url+path, verify=False).json().get('result')[0].get('data').get('package').get('metadata_modified')
    return __datetime(prod_latest_dataset) - __datetime(deploy_latest_dataset)

def __datetime(date_str):
    return datetime.strptime(date_str, '%Y-%m-%dT%H:%M:%S.%f')

if __name__ == '__main__':
    prod_url = 'https://hub.research.csiro.au/'
    deploy_url = 'https://hub-dev.research.csiro.au/'

    print('Dataset size gap between prod and deploy (prod - deploy):\t ', check_dataset_size_gap(prod_url, deploy_url))
    print('Recent update gap between prod and deploy (prod - deploy):\t ', check_date_gap_to_prod(prod_url, deploy_url))
    