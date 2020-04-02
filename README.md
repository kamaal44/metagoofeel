# Metagoofeel

Web crawler and downloader based on GNU Wget.

The goal is to be less intrusive than simply mirroring an entire website.

You can also import your own list with already crawled URLs (e.g. from Burp Suite).

Current regular expression for extracting URLs from GNU Wget's output is `"(?<=URL\:\ )[^\s]+?(?=\ 200\ OK)"` and for downloading is simply to check if the supplied keyword/regular expression is contained in a URL.

Tweak this tool to your liking by modifying regular expressions.

Tested on Kali Linux v2020.1b (64 bit).

Made for educational purposes. I hope it will help!

## How to Run

Open the GNOME Terminal from [\\src\\](https://github.com/ivan-sincek/metagoofeel/tree/master/src) and run the commands shown below.

Install required package:

```fundamental
apt-get install bc
```

Change file permissions:

```fundamental
chmod +x metagoofeel.sh
```

Run the script:

```fundamental
./metagoofeel.sh
```

Tail the crawling progress (optional):

```fundamental
tail -f metagoofeel_urls.txt
```

## Images

![Help](https://github.com/ivan-sincek/metagoofeel/blob/master/img/help.jpg)

![Crawl](https://github.com/ivan-sincek/metagoofeel/blob/master/img/crawl.jpg)

![Import](https://github.com/ivan-sincek/metagoofeel/blob/master/img/import.jpg)
