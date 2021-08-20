﻿'''Check for free names of a given (or shorter) length.

It works via Selenium which login with your login-password.
Each iteration has 1 second sleep otherwise there is a risk of being blocked.
Input: [
        max_length: int (default&recomended – 3);
        min_length: int (default – 0). Make sence if you've
                    already completed (3,0) and want to start (4,4).
    ]
Output: [
        realtime print available nicknames, errors (long responce);
        available.txt file.
    ]
'''

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from os import environ
from sys import argv
from time import sleep
from winsound import Beep


symbs: list = [chr(x) for x in range(97, 123)] + [chr(x) for x in range(48, 58)]
n_symbs: list = [chr(x) for x in range(97, 123)] + [chr(x) for x in range(48, 58)] + ['-']
result_file = open('available.txt', 'a')

s = int(argv[1]) if len(argv) > 1 else 3
e = int(argv[2]) if len(argv) > 2 else 0

driver = webdriver.Firefox()
driver.get("https://github.com/settings/admin")
login_input = driver.find_element_by_id("login_field")
password_input = driver.find_element_by_id("password")
login_input.send_keys(environ['github_login'])
password_input.send_keys(environ['github_password'])
password_input.send_keys(Keys.RETURN)

sleep(3)
WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.XPATH, "//details[@id='rename-warning-dialog']/summary"))
).click()
sleep(3)
WebDriverWait(driver, 10).until(
    EC.presence_of_element_located(
        (
            By.XPATH,
            "//details[@id='rename-warning-dialog']/details-dialog"
            + "/div[@class='Box-body overflow-auto']/button",
        )
    )
).click()
sleep(3)
nickname_field = WebDriverWait(driver, 10).until(
    EC.presence_of_element_located((By.XPATH, "//input[@name='login']"))
)
result_message = driver.find_element_by_xpath("//p[@class='note']")


def check_nickname(nn: str):
    global nickname_field, result_message, s, e, n_symbs
    if e - 1 <= len(nn) < s:
        for f in n_symbs:
            if f != '-':
                nickname_field.send_keys(Keys.CONTROL, 'a')
                nickname_field.send_keys(Keys.DELETE)
                nickname_field.send_keys(nn + f)
                while True:
                    sleep(1)
                    if result_message.text == nn + f + " is available.":
                        print(result_message.text)
                        result_file.write(nn + f + '\n')
                        break
                    elif (
                        result_message.text[: 28 + len(nn)]
                        == "Username '" + nn + f + "' is unavailable."
                    ):
                        break
                    elif (
                        result_message.text[: 28 + len(nn)]
                        == "Username " + nn + f + " is not available."
                    ):
                        break
                    else:
                        print("ALARMA: " + result_message.text)
            check_nickname(nn + f)
    elif len(nn) < s:
        for f in n_symbs:
            check_nickname(nn + f)


for i in symbs:
    check_nickname(i)