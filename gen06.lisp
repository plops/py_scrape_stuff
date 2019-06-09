(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload :cl-py-generator))

(in-package :cl-py-generator)
(let ((code
       `(do0
	 (imports (sys
		   (np numpy)
		   (pd
		    pandas)
		   pathlib
		   html
		   json
		   logging
		   ;requests
		   requests_html
		   urllib
		   time
	)) 
	 ;"from bs4 import BeautifulSoup"
	 "# pip3 install --user requests-html"
	 ;"# export PATH=$PATH:/home/martin/.local/bin"
	 "# pyppeteer-install"
		 
	 ,(let ((l `((keyword)
		     (star)
		     (page (string "1"))
		     (pageSize (string "30"))
		     (cid (string "0,1,3"))  ;; (string "0,1,4") 
		     (year (string "-1"))
		     (language (string "%E8%8B%B1%E8%AF%AD") t)
		     (region (string "-1"))
		     (status (string "-1"))
		     (orderBy (string "0"))
		     (desc (string "true")))))

	    `(def gen_url (&key ,@(loop for e in l collect
					(destructuring-bind (name &optional value dont-quote) e
					  (if value
					      `(,name ,value)
					      `(,name (string "")))))
				)
	       (with (as (open (string "/dev/shm/site")) f)
		     (setf site (dot (f.readline)
				     (strip))))
	       (return (dot (string ,(with-output-to-string (s)
				       (format s "https://www.{}/list?")
				       (loop for e in l collect
					    (destructuring-bind (name &optional value dont-quote) e
					      (format s "&~a={}" name value)))
				       ))
			    
			    (format
			     site
			     ,@(loop for e in l collect
					   (destructuring-bind (name &optional value dont-quote) e
					     (if dont-quote
						 name
						 `(urllib.parse.quote ,name)))))))
	       ))


	 
	 
	 
	 (setf url (gen_url))

	 (print (dot (string "get {}")
		     (format url)))

	 (setf session (requests_html.HTMLSession))
	 (setf r (session.get url)
	       ;content  ;(r.text.replace (string "&#8203") (string ""))
	       )
	 (r.html.render)
	 (setf elements (r.html.find (string "div[class=title-box]")))
	 (setf res (list))
	 (for (e elements)
	      (setf h (e.find (string "a") :first True))

	      (res.append
	       (dict ((string "link") (aref h.attrs (string "href")))
		     ((string "title") h.text))))
	 (setf df (pd.DataFrame res))
	 )))
  (write-source "/home/martin/stage/py_scrape_stuff/source/run_06" code))