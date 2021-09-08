'''Check for free names of a given (or shorter) length.

It works via Selenium which sign in with your login-password.
Each iteration has 1 second sleep otherwise there is a risk of being blocked.
Don't forget to download web-driver (https://github.com/mozilla/geckodriver/releases for FF)
Full cycle with (3,0) args and 1s sleep takes at least 14 hours.
                (4,4) args and 1s sleep takes at least 20.5 days ¯|_(ツ)_/¯
You can change "symbs" list to separate full cycle into parts.
Input: [
        max_length: int (default&recomended – 3);
        min_length: int (default – 0). It makes sense if you've
                    already completed (3,0) and want to start (4,4);
        start_nn: str (default 'a'). Skip all values that are less than this attribute.
    ]
Output: [
        realtime print available nicknames, errors (long responce);
        available.txt file.
    ]
'''

from os import environ
from sys import argv
from time import sleep

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


symbs: list = [chr(x) for x in range(97, 123)] + [chr(x) for x in range(48, 58)]
n_symbs: list = symbs + ['-']

max_length = int(argv[1]) if len(argv) > 1 else 3
min_length = int(argv[2]) if len(argv) > 2 else 0
first_value = str(argv[3]) if len(argv) > 3 else '0'

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
    '''Recursive main function to check nickname availability.'''
    if min_length - 1 <= len(nn) < max_length:
        for symbol in n_symbs:
            if symbol != '-' and first_value <= nn + symbol:
                nickname_field.send_keys(Keys.CONTROL, 'a')
                nickname_field.send_keys(Keys.DELETE)
                nickname_field.send_keys(nn + symbol)
                while True:
                    sleep(1)
                    if result_message.text == nn + symbol + " is available.":
                        with open('available.txt', 'a') as file:
                            file.write(nn + symbol + '\n')
                        print(result_message.text)
                        break
                    if (
                        result_message.text[: 28 + len(nn)]
                        == "Username '" + nn + symbol + "' is unavailable."
                    ):
                        break
                    if (
                        result_message.text[: 28 + len(nn)]
                        == "Username " + nn + symbol + " is not available."
                    ):
                        break
                    if (
                        result_message.text == "Username must be different."
                    ):
                        break
                    print("ALARMA: " + result_message.text)
                check_nickname(nn + symbol)
            elif nn[-1] != '-':
                check_nickname(nn + symbol)
    elif len(nn) < max_length:
        for symbol in n_symbs:
            if nn[-1] != '-' or symbol != '-':
                check_nickname(nn + symbol)


for i in symbs:
    check_nickname(i)
