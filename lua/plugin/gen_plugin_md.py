#!/usr/bin/env python3
# coding=utf-8
import re
title_pattern = r"[ \t]*-- ((?!use).*)"
plug_pattern_1 = r"[ \t]*use.*?[\"']([^\"']*?)[\"'].*-- (.*)"
plug_pattern_2 = r"[ \t]*use.*?[\"']([^\"']*?)[\"'].*"
with open("plugins.lua", "r") as f:
    content = []
    enable = 0
    for line in f:
        if "return packer.startup(function(use)" in line:
            enable = 1
        elif "-- Automatically set up your configuration after cloning packer.nvim" in line:
            enable = 0
        if enable:
            res = re.match(title_pattern, line)
            if res:
                content.append([res.group(1)])
                continue

            res = re.match(plug_pattern_1, line)
            if res:
                content[-1].append((res.group(1), res.group(2)))
                continue

            res = re.match(plug_pattern_2, line)
            if res:
                content[-1].append((res.group(1), ""))
                continue

for sub in content:
    print(f"**{sub[0]}**\n")
    print("| Plugin | Description |\n| ------ | ----------- |")
    for i in range(1, len(sub)):
        print(f"| [{sub[i][0]}](https://github.com/{sub[i][0]}) | {sub[i][1]} |")
    print()
