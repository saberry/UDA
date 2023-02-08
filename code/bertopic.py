from bertopic import BERTopic
from bertopic.vectorizers import ClassTfidfTransformer
import pandas as pd

## Vanilla ##

songs = pd.read_feather("C:/Users/sberry5/Documents/teaching/UDA/data/all_lyrics.feather")

songs = songs.dropna()

songs['lyrics'] = songs['lyrics'].astype('str')

ctfidf_model = ClassTfidfTransformer(reduce_frequent_words=True)

topic_model = BERTopic(ctfidf_model=ctfidf_model)

topics, probs = topic_model.fit_transform(songs['lyrics'].to_list())

topic_model.get_topic_info()

topic_model.get_topic(0)

topic_model.get_document_info(songs['lyrics'])

topic_model.get_representative_docs(0)

topic_model.generate_topic_labels()

topic_model.reduce_topics(songs['lyrics'].to_list(), nr_topics=10)

## Per Class ##

docs = songs["lyrics"].to_list()
targets = songs["genre"].to_list()

topics_per_class = topic_model.topics_per_class(docs, classes=targets)

topic_model.visualize_topics_per_class(topics_per_class, top_n_topics=10)
