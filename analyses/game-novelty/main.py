import duckdb
import numpy as np
import pandas as pd

from baseball_db.constants import DATABASE_NAME


def get_data() -> pd.DataFrame:
    with open('analyses/novelty/simplified_events.sql', 'r') as sqlfile:
        sql = sqlfile.read()

    con = duckdb.connect(DATABASE_NAME)
    df = con.sql(sql).df()
    con.close()

    return df


def main():
    df = get_data()

    df = (
        df.pivot(
            index=['game_id', 'game_start_date', 'season'],
            columns='event_index',
            values='event_type'
        )
        .fillna('NOEVENT')
        .reset_index()
    )

    for season in [1995, 2025]:
        game_dates = df.loc[df['season'] == season, 'game_start_date'].drop_duplicates().sort_values()

        results = []
        for game_date in game_dates:
            print(game_date)

            occurred_df = (
                df.loc[df['game_start_date'] < game_date]
                .sort_values('game_start_date', ascending=False)
            )

            games_df = df.loc[df['game_start_date'] == game_date]

            n_games = games_df.shape[0]
            occurred = occurred_df.iloc[:, 3:].values
            occurred = np.tile(occurred, (n_games, 1, 1,))

            games = games_df.iloc[:, 3:].values
            games = np.expand_dims(games, axis=1)

            event_comp = np.equal(occurred, games)
            first_diff = np.argmin(event_comp, axis=2)
            novelty_play = np.max(first_diff, axis=1)
            first_longest_similarity = np.argmax(first_diff, axis=1)

            for i, game_id in enumerate(games_df['game_id']):
                novelty_idx = novelty_play[i] + 1 # type: ignore
                play_seq = ', '.join(games[i, 0, :novelty_idx])

                recent_similar_game_id = occurred_df.iloc[first_longest_similarity[i]]['game_id']
                recent_similar_play_seq = ', '.join(occurred[i, first_longest_similarity[i], :novelty_idx])

                result = {
                    'game_id': game_id,
                    'novelty_play': novelty_idx,
                    'play_seq': play_seq,
                    'recent_similar_game_id': recent_similar_game_id,
                    'recent_similar_play_seq': recent_similar_play_seq
                }

                results.append(result)

        results = pd.DataFrame(results)
        results.to_csv(f'analyses/game-novelty/output/game-novelty-{season}.csv', index=False)


if __name__ == '__main__':
    main()
