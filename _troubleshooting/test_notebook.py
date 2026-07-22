import marimo

__generated_with = "0.23.14"
app = marimo.App()


@app.cell
def _():
    import torch

    if torch.cuda.is_available():
      print(torch.cuda.get_device_name(0))
    return


if __name__ == "__main__":
    app.run()
